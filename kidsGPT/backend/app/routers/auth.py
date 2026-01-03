"""Authentication endpoints."""

import logging
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from sqlalchemy.orm import selectinload

from app.core.database import get_db
from app.core.firebase import verify_id_token, is_firebase_configured
from app.core.dependencies import get_current_user
from app.models import User, Child
from app.schemas import (
    UserCreate, UserResponse, FirebaseLoginRequest,
    KidLoginRequest, KidLoginResponse
)

logger = logging.getLogger(__name__)

router = APIRouter()


@router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def register_user(
    user_data: UserCreate,
    db: AsyncSession = Depends(get_db)
):
    """
    Register a new parent account.

    For MVP, this is a simple registration without Firebase verification.
    In production, this would verify Firebase token.
    """
    # Check if email already exists
    result = await db.execute(
        select(User).where(User.email == user_data.email)
    )
    existing_user = result.scalar_one_or_none()

    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )

    # Create new user
    user = User(
        email=user_data.email,
        display_name=user_data.display_name,
        firebase_uid=user_data.firebase_uid,
    )
    db.add(user)
    await db.flush()
    await db.refresh(user)

    return user


@router.post("/login", response_model=UserResponse)
async def login_user(
    email: str,
    db: AsyncSession = Depends(get_db)
):
    """
    Login user by email.

    MVP: Simple email lookup.
    Production: Would verify Firebase token.
    """
    result = await db.execute(
        select(User).where(User.email == email)
    )
    user = result.scalar_one_or_none()

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )

    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="User account is deactivated"
        )

    return user


@router.post("/firebase-login", response_model=UserResponse)
async def firebase_login(
    login_data: FirebaseLoginRequest,
    db: AsyncSession = Depends(get_db)
):
    """
    Authenticate user with Firebase ID token.

    This endpoint:
    1. Verifies the Firebase ID token
    2. Creates a new user if first login, or returns existing user
    3. Updates user info if needed

    Flow:
    - Client authenticates with Firebase SDK (email/password, Google, Apple, etc.)
    - Client gets ID token from Firebase
    - Client sends ID token to this endpoint
    - Backend verifies token and returns user profile
    """
    if not is_firebase_configured():
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Firebase authentication is not configured"
        )

    # Verify the Firebase ID token
    firebase_user = verify_id_token(login_data.id_token)
    if firebase_user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired Firebase token"
        )

    # Look for existing user by Firebase UID
    result = await db.execute(
        select(User).where(User.firebase_uid == firebase_user.uid)
    )
    user = result.scalar_one_or_none()

    if user:
        # Existing user - update if needed
        updated = False
        if firebase_user.email and user.email != firebase_user.email:
            user.email = firebase_user.email
            updated = True
        if firebase_user.display_name and not user.display_name:
            user.display_name = firebase_user.display_name
            updated = True

        if updated:
            await db.flush()
            await db.refresh(user)

        if not user.is_active:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="User account is deactivated"
            )

        logger.info(f"Firebase login: existing user {user.email} (id={user.id})")
        return user

    # New user - create account
    display_name = (
        login_data.display_name
        or firebase_user.display_name
        or firebase_user.email.split("@")[0] if firebase_user.email else "User"
    )

    user = User(
        email=firebase_user.email,
        display_name=display_name,
        firebase_uid=firebase_user.uid,
    )
    db.add(user)
    await db.flush()
    await db.refresh(user)

    logger.info(f"Firebase login: new user created {user.email} (id={user.id})")
    return user


@router.get("/me", response_model=UserResponse)
async def get_current_user_profile(
    current_user: User = Depends(get_current_user)
):
    """
    Get current user profile.

    Requires Firebase authentication token in Authorization header.
    """
    return current_user


@router.get("/me-legacy", response_model=UserResponse)
async def get_current_user_legacy(
    user_id: int,  # MVP: pass user_id directly. Will be deprecated.
    db: AsyncSession = Depends(get_db)
):
    """Get current user profile (legacy - for backward compatibility)."""
    result = await db.execute(
        select(User).where(User.id == user_id)
    )
    user = result.scalar_one_or_none()

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )

    return user


@router.post("/kid-login", response_model=KidLoginResponse)
async def kid_login(
    login_data: KidLoginRequest,
    db: AsyncSession = Depends(get_db)
):
    """
    Login a child using their 6-digit PIN.

    This endpoint:
    1. Looks up the child by PIN
    2. Verifies the child is active
    3. Verifies the parent account is active
    4. Returns child info for the chat session
    """
    # Find child by PIN
    result = await db.execute(
        select(Child)
        .options(selectinload(Child.parent))
        .where(Child.login_pin == login_data.pin)
    )
    child = result.scalar_one_or_none()

    if not child:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Invalid PIN. Please check with your parent for the correct PIN."
        )

    # Check if child is active
    if not child.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="This account has been deactivated. Please ask your parent."
        )

    # Check if parent is active
    if not child.parent.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="The parent account is not active."
        )

    # Reset daily messages if needed
    child.reset_daily_messages()
    await db.flush()

    return KidLoginResponse(
        child_id=child.id,
        child_name=child.name,
        age=child.age,
        avatar_id=child.avatar_id,
        daily_limit=child.daily_message_limit,
        messages_remaining=child.daily_message_limit - child.messages_today,
        can_send_message=child.can_send_message(),
        parent_name=child.parent.display_name
    )
