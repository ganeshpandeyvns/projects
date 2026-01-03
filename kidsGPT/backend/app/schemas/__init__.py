"""Pydantic schemas for KidsGPT API."""

from app.schemas.user import (
    UserCreate,
    UserUpdate,
    UserResponse,
    ChildCreate,
    ChildUpdate,
    ChildResponse,
    ChildWithStats,
    KidLoginRequest,
    KidLoginResponse,
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
    "KidLoginRequest",
    "KidLoginResponse",
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
