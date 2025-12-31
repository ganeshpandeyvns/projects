"""Abstract base class for AI providers - enables model switching."""

from abc import ABC, abstractmethod
from dataclasses import dataclass
from typing import AsyncGenerator, List, Dict, Optional


@dataclass
class ChatMessage:
    """Represents a chat message."""
    role: str  # "user", "assistant", "system"
    content: str


@dataclass
class ModerationResult:
    """Result from content moderation check."""
    is_safe: bool
    categories: Dict[str, bool]  # e.g., {"violence": False, "sexual": False}
    category_scores: Dict[str, float]  # Confidence scores
    flagged_categories: List[str]  # List of categories that were flagged


@dataclass
class ChatResponse:
    """Response from AI chat completion."""
    content: str
    model: str
    tokens_used: int
    finish_reason: str


class AIProvider(ABC):
    """Abstract base for all AI providers - enables model switching."""

    @property
    @abstractmethod
    def name(self) -> str:
        """Provider name (e.g., 'openai', 'anthropic')."""
        pass

    @property
    @abstractmethod
    def model(self) -> str:
        """Current model being used."""
        pass

    @abstractmethod
    async def chat(
        self,
        messages: List[ChatMessage],
        system_prompt: str,
        max_tokens: int = 500,
        temperature: float = 0.7,
    ) -> ChatResponse:
        """
        Generate a chat completion response.

        Args:
            messages: List of conversation messages
            system_prompt: System prompt to guide AI behavior
            max_tokens: Maximum tokens in response
            temperature: Creativity/randomness (0-1)

        Returns:
            ChatResponse with the AI's reply
        """
        pass

    @abstractmethod
    async def chat_stream(
        self,
        messages: List[ChatMessage],
        system_prompt: str,
        max_tokens: int = 500,
        temperature: float = 0.7,
    ) -> AsyncGenerator[str, None]:
        """
        Generate a streaming chat completion response.

        Args:
            messages: List of conversation messages
            system_prompt: System prompt to guide AI behavior
            max_tokens: Maximum tokens in response
            temperature: Creativity/randomness (0-1)

        Yields:
            String chunks of the response as they arrive
        """
        pass

    @abstractmethod
    async def moderate(self, text: str) -> ModerationResult:
        """
        Check content for safety/appropriateness.

        Args:
            text: Text to check

        Returns:
            ModerationResult with safety assessment
        """
        pass

    def format_messages_for_api(
        self,
        messages: List[ChatMessage],
        system_prompt: str
    ) -> List[Dict]:
        """
        Format messages for the specific API.
        Override in subclasses if needed.
        """
        formatted = [{"role": "system", "content": system_prompt}]
        for msg in messages:
            formatted.append({"role": msg.role, "content": msg.content})
        return formatted
