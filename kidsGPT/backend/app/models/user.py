"""User and Child database models."""

import random
import string
from datetime import datetime, date
from enum import Enum as PyEnum
from typing import Optional, List
from sqlalchemy import String, Integer, Boolean, DateTime, Date, ForeignKey, JSON, Enum, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base


def generate_kid_pin() -> str:
    """Generate a unique 6-digit PIN for kid login."""
    return ''.join(random.choices(string.digits, k=6))


class UserRole(str, PyEnum):
    """User roles."""
    PARENT = "parent"
    ADMIN = "admin"


class SubscriptionTier(str, PyEnum):
    """Subscription tiers."""
    FREE = "free"
    BASIC = "basic"
    PREMIUM = "premium"


class User(Base):
    """Parent/Admin user model."""
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    email: Mapped[str] = mapped_column(String(255), unique=True, index=True, nullable=False)
    firebase_uid: Mapped[Optional[str]] = mapped_column(String(128), unique=True, index=True, nullable=True)
    display_name: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    role: Mapped[UserRole] = mapped_column(Enum(UserRole), default=UserRole.PARENT, nullable=False)
    subscription_tier: Mapped[SubscriptionTier] = mapped_column(
        Enum(SubscriptionTier), default=SubscriptionTier.FREE, nullable=False
    )
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False
    )

    # Relationships
    children: Mapped[List["Child"]] = relationship("Child", back_populates="parent", cascade="all, delete-orphan")

    def __repr__(self) -> str:
        return f"<User(id={self.id}, email={self.email}, role={self.role})>"


class Child(Base):
    """Child profile model."""
    __tablename__ = "children"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    parent_id: Mapped[int] = mapped_column(Integer, ForeignKey("users.id"), nullable=False)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    age: Mapped[int] = mapped_column(Integer, nullable=False)  # 3-13
    login_pin: Mapped[str] = mapped_column(String(6), unique=True, index=True, nullable=False, default=generate_kid_pin)
    avatar_id: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)  # For UI customization
    interests: Mapped[Optional[dict]] = mapped_column(JSON, nullable=True)  # ["dinosaurs", "space", "art"]
    learning_goals: Mapped[Optional[dict]] = mapped_column(JSON, nullable=True)  # Parent-defined goals
    daily_message_limit: Mapped[int] = mapped_column(Integer, default=50, nullable=False)
    messages_today: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    last_message_date: Mapped[Optional[date]] = mapped_column(Date, nullable=True)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False
    )

    # Relationships
    parent: Mapped["User"] = relationship("User", back_populates="children")
    conversations: Mapped[List["Conversation"]] = relationship(
        "Conversation", back_populates="child", cascade="all, delete-orphan"
    )

    def __repr__(self) -> str:
        return f"<Child(id={self.id}, name={self.name}, age={self.age})>"

    def reset_daily_messages(self) -> None:
        """Reset daily message count if it's a new day."""
        today = date.today()
        if self.last_message_date != today:
            self.messages_today = 0
            self.last_message_date = today

    def can_send_message(self) -> bool:
        """Check if child can send more messages today."""
        self.reset_daily_messages()
        return self.messages_today < self.daily_message_limit

    def increment_message_count(self) -> None:
        """Increment daily message count."""
        self.reset_daily_messages()
        self.messages_today += 1

    def regenerate_pin(self) -> str:
        """Generate a new login PIN for this child."""
        self.login_pin = generate_kid_pin()
        return self.login_pin
