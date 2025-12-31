"""Children profile management endpoints."""

from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func

from app.core.database import get_db
from app.models import User, Child, Conversation, Message
from app.schemas import ChildCreate, ChildUpdate, ChildResponse, ChildWithStats

router = APIRouter()


@router.post("/", response_model=ChildResponse, status_code=status.HTTP_201_CREATED)
async def create_child(
    child_data: ChildCreate,
    parent_id: int,  # MVP: pass directly. Production: extract from token
    db: AsyncSession = Depends(get_db)
):
    """Create a new child profile for a parent."""
    # Verify parent exists
    result = await db.execute(
        select(User).where(User.id == parent_id)
    )
    parent = result.scalar_one_or_none()

    if not parent:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Parent not found"
        )

    # Check subscription limits for number of children
    children_result = await db.execute(
        select(func.count(Child.id)).where(Child.parent_id == parent_id)
    )
    children_count = children_result.scalar()

    # Subscription limits
    limits = {
        "free": 1,
        "basic": 3,
        "premium": 5,
    }
    max_children = limits.get(parent.subscription_tier.value, 1)

    if children_count >= max_children:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=f"Maximum {max_children} child profiles allowed for {parent.subscription_tier.value} tier"
        )

    # Create child profile
    child = Child(
        parent_id=parent_id,
        name=child_data.name,
        age=child_data.age,
        avatar_id=child_data.avatar_id,
        interests=child_data.interests,
        learning_goals=child_data.learning_goals,
        daily_message_limit=child_data.daily_message_limit,
    )
    db.add(child)
    await db.flush()
    await db.refresh(child)

    return child


@router.get("/", response_model=List[ChildWithStats])
async def list_children(
    parent_id: int,  # MVP: pass directly. Production: extract from token
    db: AsyncSession = Depends(get_db)
):
    """List all children for a parent with stats."""
    result = await db.execute(
        select(Child).where(Child.parent_id == parent_id).order_by(Child.created_at)
    )
    children = result.scalars().all()

    # Build response with stats
    children_with_stats = []
    for child in children:
        # Get conversation count
        conv_result = await db.execute(
            select(func.count(Conversation.id)).where(Conversation.child_id == child.id)
        )
        total_conversations = conv_result.scalar() or 0

        # Get message count
        msg_result = await db.execute(
            select(func.count(Message.id))
            .join(Conversation)
            .where(Conversation.child_id == child.id)
        )
        total_messages = msg_result.scalar() or 0

        child_data = ChildWithStats(
            id=child.id,
            parent_id=child.parent_id,
            name=child.name,
            age=child.age,
            avatar_id=child.avatar_id,
            interests=child.interests,
            learning_goals=child.learning_goals,
            daily_message_limit=child.daily_message_limit,
            messages_today=child.messages_today,
            last_message_date=child.last_message_date,
            is_active=child.is_active,
            created_at=child.created_at,
            total_conversations=total_conversations,
            total_messages=total_messages,
            can_send_message=child.can_send_message(),
        )
        children_with_stats.append(child_data)

    return children_with_stats


@router.get("/{child_id}", response_model=ChildWithStats)
async def get_child(
    child_id: int,
    parent_id: int,  # MVP: pass directly. Production: verify ownership via token
    db: AsyncSession = Depends(get_db)
):
    """Get a specific child profile with stats."""
    result = await db.execute(
        select(Child).where(Child.id == child_id, Child.parent_id == parent_id)
    )
    child = result.scalar_one_or_none()

    if not child:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Child not found"
        )

    # Get stats
    conv_result = await db.execute(
        select(func.count(Conversation.id)).where(Conversation.child_id == child.id)
    )
    total_conversations = conv_result.scalar() or 0

    msg_result = await db.execute(
        select(func.count(Message.id))
        .join(Conversation)
        .where(Conversation.child_id == child.id)
    )
    total_messages = msg_result.scalar() or 0

    return ChildWithStats(
        id=child.id,
        parent_id=child.parent_id,
        name=child.name,
        age=child.age,
        avatar_id=child.avatar_id,
        interests=child.interests,
        learning_goals=child.learning_goals,
        daily_message_limit=child.daily_message_limit,
        messages_today=child.messages_today,
        last_message_date=child.last_message_date,
        is_active=child.is_active,
        created_at=child.created_at,
        total_conversations=total_conversations,
        total_messages=total_messages,
        can_send_message=child.can_send_message(),
    )


@router.patch("/{child_id}", response_model=ChildResponse)
async def update_child(
    child_id: int,
    child_data: ChildUpdate,
    parent_id: int,  # MVP: pass directly
    db: AsyncSession = Depends(get_db)
):
    """Update a child profile."""
    result = await db.execute(
        select(Child).where(Child.id == child_id, Child.parent_id == parent_id)
    )
    child = result.scalar_one_or_none()

    if not child:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Child not found"
        )

    # Update fields that were provided
    update_data = child_data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(child, field, value)

    await db.flush()
    await db.refresh(child)

    return child


@router.delete("/{child_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_child(
    child_id: int,
    parent_id: int,  # MVP: pass directly
    db: AsyncSession = Depends(get_db)
):
    """Delete a child profile and all associated data."""
    result = await db.execute(
        select(Child).where(Child.id == child_id, Child.parent_id == parent_id)
    )
    child = result.scalar_one_or_none()

    if not child:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Child not found"
        )

    await db.delete(child)
    await db.flush()
