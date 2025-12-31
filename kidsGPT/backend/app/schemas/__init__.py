"""Pydantic schemas for KidsGPT API."""

from app.schemas.user import (
    UserCreate,
    UserUpdate,
    UserResponse,
    ChildCreate,
    ChildUpdate,
    ChildResponse,
    ChildWithStats,
)
from app.schemas.chat import (
    MessageCreate,
    MessageResponse,
    ConversationCreate,
    ConversationResponse,
    ConversationWithMessages,
    ChatRequest,
    ChatResponse,
    ChatStreamChunk,
    ConversationHistory,
)

__all__ = [
    # User schemas
    "UserCreate",
    "UserUpdate",
    "UserResponse",
    "ChildCreate",
    "ChildUpdate",
    "ChildResponse",
    "ChildWithStats",
    # Chat schemas
    "MessageCreate",
    "MessageResponse",
    "ConversationCreate",
    "ConversationResponse",
    "ConversationWithMessages",
    "ChatRequest",
    "ChatResponse",
    "ChatStreamChunk",
    "ConversationHistory",
]
