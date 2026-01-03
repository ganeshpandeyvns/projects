"""Chat endpoints - core KidsGPT functionality."""

from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.responses import StreamingResponse
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, desc
import json

from app.core.database import get_db
from app.models import Child, Conversation, Message, MessageRole
from app.schemas import (
    ChatRequest, ChatResponse, MessageResponse,
    ConversationResponse, ConversationWithMessages, ConversationHistory
)
from app.services.ai_service import get_ai_service
from ai.providers.base import ChatMessage

router = APIRouter()


@router.post("", response_model=ChatResponse)
async def send_message(
    request: ChatRequest,
    db: AsyncSession = Depends(get_db)
):
    """
    Send a message and get AI response.

    This is the main chat endpoint for children.
    """
    # Get child profile
    result = await db.execute(
        select(Child).where(Child.id == request.child_id)
    )
    child = result.scalar_one_or_none()

    if not child:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Child profile not found"
        )

    if not child.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Child profile is not active"
        )

    # Check daily message limit
    if not child.can_send_message():
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail=f"Daily message limit ({child.daily_message_limit}) reached. Try again tomorrow!"
        )

    # Get or create conversation
    conversation: Conversation
    if request.conversation_id:
        conv_result = await db.execute(
            select(Conversation).where(
                Conversation.id == request.conversation_id,
                Conversation.child_id == request.child_id
            )
        )
        conversation = conv_result.scalar_one_or_none()
        if not conversation:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Conversation not found"
            )
    else:
        # Create new conversation
        conversation = Conversation(
            child_id=request.child_id,
            title=request.message[:50] + "..." if len(request.message) > 50 else request.message
        )
        db.add(conversation)
        await db.flush()

    # Get conversation history for context
    history_result = await db.execute(
        select(Message)
        .where(Message.conversation_id == conversation.id)
        .order_by(Message.created_at)
        .limit(20)  # Limit context window
    )
    history_messages = history_result.scalars().all()

    # Build message history for AI
    ai_messages: List[ChatMessage] = []
    for msg in history_messages:
        role = "user" if msg.role == MessageRole.CHILD else "assistant"
        ai_messages.append(ChatMessage(role=role, content=msg.content))

    # Add current message
    ai_messages.append(ChatMessage(role="user", content=request.message))

    # Save child's message
    child_message = Message(
        conversation_id=conversation.id,
        role=MessageRole.CHILD,
        content=request.message,
    )
    db.add(child_message)
    conversation.message_count += 1

    # Get AI response
    ai_service = get_ai_service()
    try:
        ai_response = await ai_service.chat(
            child_age=child.age,
            messages=ai_messages,
            child_name=child.name,
            interests=child.interests or [],
            learning_goals=child.learning_goals or [],
        )
    except Exception as e:
        # Log error and return friendly message
        print(f"AI Error: {e}")
        ai_response_content = (
            "Oops! My brain got a little confused there. "
            "Can you try asking me again? I want to help!"
        )
        ai_model = "error"
        tokens_used = 0
    else:
        ai_response_content = ai_response.content
        ai_model = ai_response.model
        tokens_used = ai_response.tokens_used

    # Save AI response
    assistant_message = Message(
        conversation_id=conversation.id,
        role=MessageRole.ASSISTANT,
        content=ai_response_content,
        ai_model=ai_model,
        tokens_used=tokens_used,
    )
    db.add(assistant_message)
    conversation.message_count += 1

    # Update child's daily message count
    child.increment_message_count()

    await db.flush()
    await db.refresh(child_message)
    await db.refresh(assistant_message)

    # Calculate remaining messages
    messages_remaining = child.daily_message_limit - child.messages_today

    return ChatResponse(
        conversation_id=conversation.id,
        message=MessageResponse(
            id=child_message.id,
            conversation_id=conversation.id,
            role=MessageRole.CHILD,
            content=child_message.content,
            is_flagged=child_message.is_flagged,
            created_at=child_message.created_at,
        ),
        response=MessageResponse(
            id=assistant_message.id,
            conversation_id=conversation.id,
            role=MessageRole.ASSISTANT,
            content=assistant_message.content,
            is_flagged=assistant_message.is_flagged,
            created_at=assistant_message.created_at,
        ),
        messages_remaining_today=messages_remaining,
    )


@router.get("/conversations/{child_id}", response_model=List[ConversationResponse])
async def list_conversations(
    child_id: int,
    parent_id: int,  # For verification
    limit: int = 20,
    offset: int = 0,
    db: AsyncSession = Depends(get_db)
):
    """List all conversations for a child (parent view)."""
    # Verify parent owns child
    result = await db.execute(
        select(Child).where(Child.id == child_id, Child.parent_id == parent_id)
    )
    child = result.scalar_one_or_none()

    if not child:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Child not found"
        )

    # Get conversations
    conv_result = await db.execute(
        select(Conversation)
        .where(Conversation.child_id == child_id)
        .order_by(desc(Conversation.started_at))
        .limit(limit)
        .offset(offset)
    )
    conversations = conv_result.scalars().all()

    return [
        ConversationResponse(
            id=conv.id,
            child_id=conv.child_id,
            title=conv.title,
            started_at=conv.started_at,
            ended_at=conv.ended_at,
            is_flagged=conv.is_flagged,
            message_count=conv.message_count,
        )
        for conv in conversations
    ]


@router.get("/conversation/{conversation_id}", response_model=ConversationWithMessages)
async def get_conversation(
    conversation_id: int,
    parent_id: int,  # For verification
    db: AsyncSession = Depends(get_db)
):
    """Get a conversation with all messages (parent view)."""
    # Get conversation
    result = await db.execute(
        select(Conversation).where(Conversation.id == conversation_id)
    )
    conversation = result.scalar_one_or_none()

    if not conversation:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Conversation not found"
        )

    # Verify parent owns the child
    child_result = await db.execute(
        select(Child).where(
            Child.id == conversation.child_id,
            Child.parent_id == parent_id
        )
    )
    child = child_result.scalar_one_or_none()

    if not child:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access denied"
        )

    # Get messages
    msg_result = await db.execute(
        select(Message)
        .where(Message.conversation_id == conversation_id)
        .order_by(Message.created_at)
    )
    messages = msg_result.scalars().all()

    return ConversationWithMessages(
        id=conversation.id,
        child_id=conversation.child_id,
        title=conversation.title,
        started_at=conversation.started_at,
        ended_at=conversation.ended_at,
        is_flagged=conversation.is_flagged,
        message_count=conversation.message_count,
        messages=[
            MessageResponse(
                id=msg.id,
                conversation_id=msg.conversation_id,
                role=msg.role,
                content=msg.content,
                is_flagged=msg.is_flagged,
                created_at=msg.created_at,
            )
            for msg in messages
        ],
    )


@router.get("/today/{child_id}")
async def get_today_stats(
    child_id: int,
    db: AsyncSession = Depends(get_db)
):
    """Get today's chat stats for a child (for kids UI)."""
    result = await db.execute(
        select(Child).where(Child.id == child_id)
    )
    child = result.scalar_one_or_none()

    if not child:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Child not found"
        )

    # Reset if new day
    child.reset_daily_messages()
    await db.flush()

    return {
        "child_id": child.id,
        "child_name": child.name,
        "messages_sent_today": child.messages_today,
        "daily_limit": child.daily_message_limit,
        "messages_remaining": child.daily_message_limit - child.messages_today,
        "can_send_message": child.can_send_message(),
    }


@router.post("/stream", include_in_schema=True)
async def stream_message(
    request: ChatRequest,
    db: AsyncSession = Depends(get_db)
):
    """
    Stream a chat response (for real-time UI).

    Returns Server-Sent Events stream.
    """
    # Get child profile
    result = await db.execute(
        select(Child).where(Child.id == request.child_id)
    )
    child = result.scalar_one_or_none()

    if not child:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Child profile not found"
        )

    if not child.can_send_message():
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="Daily message limit reached"
        )

    async def generate():
        """Generate SSE stream."""
        ai_service = get_ai_service()

        # Build simple message list (just the current message for now)
        ai_messages = [ChatMessage(role="user", content=request.message)]

        try:
            async for chunk in ai_service.chat_stream(
                child_age=child.age,
                messages=ai_messages,
                child_name=child.name,
                interests=child.interests or [],
                learning_goals=child.learning_goals or [],
            ):
                yield f"data: {json.dumps({'chunk': chunk})}\n\n"

            yield f"data: {json.dumps({'done': True})}\n\n"
        except Exception as e:
            yield f"data: {json.dumps({'error': str(e)})}\n\n"

    return StreamingResponse(
        generate(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
        }
    )
