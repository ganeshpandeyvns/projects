"""Admin endpoints - System management and oversight."""

from typing import List, Optional
from datetime import datetime, timedelta
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, desc
from pydantic import BaseModel

from app.core.database import get_db
from app.models import User, Child, Conversation, Message, UserRole

router = APIRouter()


# Schemas
class AdminStats(BaseModel):
    total_users: int
    total_children: int
    total_conversations: int
    total_messages: int
    messages_today: int
    active_users_today: int
    flagged_conversations: int


class UserListItem(BaseModel):
    id: int
    email: str
    display_name: Optional[str]
    role: str
    subscription_tier: str
    is_active: bool
    created_at: datetime
    children_count: int
    total_messages: int

    class Config:
        from_attributes = True


class SystemConfig(BaseModel):
    ai_provider: str = "openai"
    default_daily_limit: int = 50
    max_children_free: int = 1
    max_children_basic: int = 3
    max_children_premium: int = 5
    content_filter_level: str = "strict"


# In-memory config (would be database in production)
_system_config = SystemConfig()


@router.get("/stats", response_model=AdminStats)
async def get_admin_stats(
    admin_id: int,
    db: AsyncSession = Depends(get_db)
):
    """Get system-wide statistics."""
    # Verify admin role
    result = await db.execute(
        select(User).where(User.id == admin_id, User.role == UserRole.ADMIN)
    )
    admin = result.scalar_one_or_none()
    if not admin:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin access required"
        )

    # Get counts
    users_count = await db.execute(select(func.count(User.id)))
    children_count = await db.execute(select(func.count(Child.id)))
    conv_count = await db.execute(select(func.count(Conversation.id)))
    msg_count = await db.execute(select(func.count(Message.id)))

    # Messages today
    today = datetime.utcnow().date()
    today_start = datetime.combine(today, datetime.min.time())
    messages_today = await db.execute(
        select(func.count(Message.id)).where(Message.created_at >= today_start)
    )

    # Flagged conversations
    flagged = await db.execute(
        select(func.count(Conversation.id)).where(Conversation.is_flagged == True)
    )

    return AdminStats(
        total_users=users_count.scalar() or 0,
        total_children=children_count.scalar() or 0,
        total_conversations=conv_count.scalar() or 0,
        total_messages=msg_count.scalar() or 0,
        messages_today=messages_today.scalar() or 0,
        active_users_today=0,  # Simplified for MVP
        flagged_conversations=flagged.scalar() or 0,
    )


@router.get("/users", response_model=List[UserListItem])
async def list_users(
    admin_id: int,
    limit: int = 50,
    offset: int = 0,
    db: AsyncSession = Depends(get_db)
):
    """List all users with their stats."""
    # Verify admin
    result = await db.execute(
        select(User).where(User.id == admin_id, User.role == UserRole.ADMIN)
    )
    if not result.scalar_one_or_none():
        raise HTTPException(status_code=403, detail="Admin access required")

    # Get users with stats
    users_result = await db.execute(
        select(User).order_by(desc(User.created_at)).limit(limit).offset(offset)
    )
    users = users_result.scalars().all()

    user_items = []
    for user in users:
        # Count children
        children_result = await db.execute(
            select(func.count(Child.id)).where(Child.parent_id == user.id)
        )
        children_count = children_result.scalar() or 0

        # Count messages
        msg_result = await db.execute(
            select(func.count(Message.id))
            .join(Conversation, Message.conversation_id == Conversation.id)
            .join(Child, Conversation.child_id == Child.id)
            .where(Child.parent_id == user.id)
        )
        total_messages = msg_result.scalar() or 0

        user_items.append(UserListItem(
            id=user.id,
            email=user.email,
            display_name=user.display_name,
            role=user.role.value if hasattr(user.role, 'value') else str(user.role),
            subscription_tier=user.subscription_tier.value if hasattr(user.subscription_tier, 'value') else str(user.subscription_tier),
            is_active=user.is_active,
            created_at=user.created_at,
            children_count=children_count,
            total_messages=total_messages,
        ))

    return user_items


@router.patch("/users/{user_id}/subscription")
async def update_subscription(
    user_id: int,
    admin_id: int,
    tier: str,
    db: AsyncSession = Depends(get_db)
):
    """Update user subscription tier."""
    # Verify admin
    admin_result = await db.execute(
        select(User).where(User.id == admin_id, User.role == UserRole.ADMIN)
    )
    if not admin_result.scalar_one_or_none():
        raise HTTPException(status_code=403, detail="Admin access required")

    # Update user
    user_result = await db.execute(select(User).where(User.id == user_id))
    user = user_result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    from app.models.user import SubscriptionTier
    try:
        user.subscription_tier = SubscriptionTier(tier.upper())
    except ValueError:
        raise HTTPException(status_code=400, detail=f"Invalid tier: {tier}")

    await db.flush()
    return {"message": f"Updated user {user_id} to {tier} tier"}


@router.patch("/users/{user_id}/toggle-active")
async def toggle_user_active(
    user_id: int,
    admin_id: int,
    db: AsyncSession = Depends(get_db)
):
    """Enable/disable a user account."""
    # Verify admin
    admin_result = await db.execute(
        select(User).where(User.id == admin_id, User.role == UserRole.ADMIN)
    )
    if not admin_result.scalar_one_or_none():
        raise HTTPException(status_code=403, detail="Admin access required")

    user_result = await db.execute(select(User).where(User.id == user_id))
    user = user_result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    user.is_active = not user.is_active
    await db.flush()

    return {"message": f"User {user_id} is now {'active' if user.is_active else 'inactive'}"}


@router.get("/flagged-conversations")
async def get_flagged_conversations(
    admin_id: int,
    limit: int = 20,
    db: AsyncSession = Depends(get_db)
):
    """Get conversations that have been flagged for review."""
    # Verify admin
    admin_result = await db.execute(
        select(User).where(User.id == admin_id, User.role == UserRole.ADMIN)
    )
    if not admin_result.scalar_one_or_none():
        raise HTTPException(status_code=403, detail="Admin access required")

    result = await db.execute(
        select(Conversation)
        .where(Conversation.is_flagged == True)
        .order_by(desc(Conversation.started_at))
        .limit(limit)
    )
    conversations = result.scalars().all()

    flagged_list = []
    for conv in conversations:
        # Get child info
        child_result = await db.execute(
            select(Child).where(Child.id == conv.child_id)
        )
        child = child_result.scalar_one_or_none()

        # Get messages
        msg_result = await db.execute(
            select(Message)
            .where(Message.conversation_id == conv.id)
            .order_by(Message.created_at)
        )
        messages = msg_result.scalars().all()

        flagged_list.append({
            "id": conv.id,
            "child_name": child.name if child else "Unknown",
            "child_age": child.age if child else 0,
            "title": conv.title,
            "started_at": conv.started_at.isoformat(),
            "flag_reason": conv.flag_reason,
            "messages": [
                {
                    "role": msg.role.value if hasattr(msg.role, 'value') else str(msg.role),
                    "content": msg.content,
                    "is_flagged": msg.is_flagged,
                }
                for msg in messages
            ]
        })

    return flagged_list


@router.get("/config", response_model=SystemConfig)
async def get_system_config(admin_id: int, db: AsyncSession = Depends(get_db)):
    """Get current system configuration."""
    # Verify admin
    admin_result = await db.execute(
        select(User).where(User.id == admin_id, User.role == UserRole.ADMIN)
    )
    if not admin_result.scalar_one_or_none():
        raise HTTPException(status_code=403, detail="Admin access required")

    return _system_config


@router.patch("/config")
async def update_system_config(
    admin_id: int,
    config: SystemConfig,
    db: AsyncSession = Depends(get_db)
):
    """Update system configuration."""
    global _system_config

    # Verify admin
    admin_result = await db.execute(
        select(User).where(User.id == admin_id, User.role == UserRole.ADMIN)
    )
    if not admin_result.scalar_one_or_none():
        raise HTTPException(status_code=403, detail="Admin access required")

    _system_config = config
    return {"message": "Configuration updated", "config": config}


@router.post("/create-admin")
async def create_admin_user(
    email: str,
    display_name: str = "Admin",
    db: AsyncSession = Depends(get_db)
):
    """Create an admin user (for initial setup only)."""
    # Check if any admin exists
    existing = await db.execute(
        select(User).where(User.role == UserRole.ADMIN)
    )
    if existing.scalar_one_or_none():
        raise HTTPException(
            status_code=400,
            detail="Admin already exists. Use existing admin to create more."
        )

    # Create admin
    admin = User(
        email=email,
        display_name=display_name,
        role=UserRole.ADMIN,
    )
    db.add(admin)
    await db.flush()
    await db.refresh(admin)

    return {
        "id": admin.id,
        "email": admin.email,
        "role": "admin",
        "message": "Admin user created successfully"
    }
