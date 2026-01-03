"""FastAPI dependencies for authentication and authorization."""

from typing import Optional

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.core.database import get_db
from app.core.firebase import verify_id_token, is_firebase_configured, FirebaseUser
from app.models import User


# HTTP Bearer token scheme
security = HTTPBearer(auto_error=False)


async def get_firebase_user(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(security),
) -> Optional[FirebaseUser]:
    """
    Extract and verify Firebase user from Authorization header.

    Returns FirebaseUser if valid token, None if no token provided.
    Raises HTTPException if token is invalid.
    """
    if credentials is None:
        return None

    if not is_firebase_configured():
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Authentication service not configured"
        )

    firebase_user = verify_id_token(credentials.credentials)

    if firebase_user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired authentication token",
            headers={"WWW-Authenticate": "Bearer"},
        )

    return firebase_user


async def get_current_user(
    firebase_user: FirebaseUser = Depends(get_firebase_user),
    db: AsyncSession = Depends(get_db),
) -> User:
    """
    Get the current authenticated user from the database.

    This dependency:
    1. Verifies the Firebase token
    2. Looks up the user by firebase_uid
    3. Returns the User model

    Raises HTTPException if:
    - No token provided (401)
    - Invalid token (401)
    - User not found in database (404)
    - User is deactivated (403)
    """
    if firebase_user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication required",
            headers={"WWW-Authenticate": "Bearer"},
        )

    # Look up user by Firebase UID
    result = await db.execute(
        select(User).where(User.firebase_uid == firebase_user.uid)
    )
    user = result.scalar_one_or_none()

    if user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found. Please complete registration first."
        )

    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="User account is deactivated"
        )

    return user


async def get_current_user_optional(
    firebase_user: Optional[FirebaseUser] = Depends(get_firebase_user),
    db: AsyncSession = Depends(get_db),
) -> Optional[User]:
    """
    Optionally get the current authenticated user.

    Similar to get_current_user but returns None instead of raising
    an exception if no token is provided.

    Use this for routes that work differently for authenticated vs anonymous users.
    """
    if firebase_user is None:
        return None

    result = await db.execute(
        select(User).where(User.firebase_uid == firebase_user.uid)
    )
    user = result.scalar_one_or_none()

    if user is None or not user.is_active:
        return None

    return user
