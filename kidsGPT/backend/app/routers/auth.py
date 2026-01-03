"""Authentication endpoints."""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from sqlalchemy.orm import selectinload

from app.core.database import get_db
from app.models import User, Child
from app.schemas import UserCreate, UserResponse, KidLoginRequest, KidLoginResponse

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


@router.get("/me", response_model=UserResponse)
async def get_current_user(
    user_id: int,  # MVP: pass user_id directly. Production: extract from token
    db: AsyncSession = Depends(get_db)
):
    """Get current user profile."""
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
