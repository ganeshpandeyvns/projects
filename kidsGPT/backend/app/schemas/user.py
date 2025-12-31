"""Pydantic schemas for User and Child models."""

from datetime import datetime, date
from typing import Optional, List
from pydantic import BaseModel, EmailStr, Field, field_validator

from app.models.user import UserRole, SubscriptionTier


# --- User Schemas ---

class UserBase(BaseModel):
    """Base user schema."""
    email: EmailStr
    display_name: Optional[str] = None


class UserCreate(UserBase):
    """Schema for creating a new user."""
    firebase_uid: Optional[str] = None


class UserUpdate(BaseModel):
    """Schema for updating a user."""
    display_name: Optional[str] = None
    subscription_tier: Optional[SubscriptionTier] = None


class UserResponse(UserBase):
    """Schema for user response."""
    id: int
    role: UserRole
    subscription_tier: SubscriptionTier
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True


# --- Child Schemas ---

class ChildBase(BaseModel):
    """Base child schema."""
    name: str = Field(..., min_length=1, max_length=100)
    age: int = Field(..., ge=3, le=13, description="Child's age must be between 3 and 13")


class ChildCreate(ChildBase):
    """Schema for creating a new child profile."""
    avatar_id: Optional[str] = None
    interests: Optional[List[str]] = None
    learning_goals: Optional[List[str]] = None
    daily_message_limit: int = Field(default=50, ge=1, le=1000)

    @field_validator('interests', 'learning_goals', mode='before')
    @classmethod
    def validate_list_fields(cls, v):
        """Ensure list fields are valid."""
        if v is None:
            return None
        if isinstance(v, list):
            return [str(item).strip() for item in v if item]
        return None


class ChildUpdate(BaseModel):
    """Schema for updating a child profile."""
    name: Optional[str] = Field(None, min_length=1, max_length=100)
    age: Optional[int] = Field(None, ge=3, le=13)
    avatar_id: Optional[str] = None
    interests: Optional[List[str]] = None
    learning_goals: Optional[List[str]] = None
    daily_message_limit: Optional[int] = Field(None, ge=1, le=1000)
    is_active: Optional[bool] = None


class ChildResponse(ChildBase):
    """Schema for child response."""
    id: int
    parent_id: int
    avatar_id: Optional[str]
    interests: Optional[List[str]]
    learning_goals: Optional[List[str]]
    daily_message_limit: int
    messages_today: int
    last_message_date: Optional[date]
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True


class ChildWithStats(ChildResponse):
    """Child response with additional stats."""
    total_conversations: int = 0
    total_messages: int = 0
    can_send_message: bool = True
