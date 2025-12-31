"""Pydantic schemas for Chat and Conversation models."""

from datetime import datetime
from typing import Optional, List
from pydantic import BaseModel, Field

from app.models.conversation import MessageRole


# --- Message Schemas ---

class MessageBase(BaseModel):
    """Base message schema."""
    content: str = Field(..., min_length=1, max_length=2000)


class MessageCreate(MessageBase):
    """Schema for creating a new message (child input)."""
    pass


class MessageResponse(MessageBase):
    """Schema for message response."""
    id: int
    conversation_id: int
    role: MessageRole
    is_flagged: bool
    created_at: datetime

    class Config:
        from_attributes = True


# --- Conversation Schemas ---

class ConversationBase(BaseModel):
    """Base conversation schema."""
    title: Optional[str] = None


class ConversationCreate(ConversationBase):
    """Schema for creating a new conversation."""
    child_id: int


class ConversationResponse(ConversationBase):
    """Schema for conversation response."""
    id: int
    child_id: int
    started_at: datetime
    ended_at: Optional[datetime]
    is_flagged: bool
    message_count: int

    class Config:
        from_attributes = True


class ConversationWithMessages(ConversationResponse):
    """Conversation with all messages."""
    messages: List[MessageResponse] = []


# --- Chat Request/Response ---

class ChatRequest(BaseModel):
    """Schema for chat API request."""
    child_id: int
    message: str = Field(..., min_length=1, max_length=2000)
    conversation_id: Optional[int] = None  # None = start new conversation


class ChatResponse(BaseModel):
    """Schema for chat API response."""
    conversation_id: int
    message: MessageResponse
    response: MessageResponse
    messages_remaining_today: int
    safety_note: Optional[str] = None  # If content was flagged/modified


class ChatStreamChunk(BaseModel):
    """Schema for streaming chat response chunks."""
    conversation_id: int
    chunk: str
    is_complete: bool = False
    message_id: Optional[int] = None  # Set when complete


# --- History ---

class ConversationHistory(BaseModel):
    """Schema for conversation history (parent view)."""
    conversations: List[ConversationWithMessages]
    total_count: int
    page: int
    page_size: int
