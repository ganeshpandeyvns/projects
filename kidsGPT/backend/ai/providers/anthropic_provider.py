"""Anthropic Claude provider implementation."""

from typing import AsyncGenerator, List, Dict
from anthropic import AsyncAnthropic

from ai.providers.base import AIProvider, ChatMessage, ChatResponse, ModerationResult
from app.core.config import settings


class AnthropicProvider(AIProvider):
    """Anthropic Claude provider implementation."""

    def __init__(
        self,
        api_key: str = None,
        model: str = None
    ):
        """
        Initialize Anthropic provider.

        Args:
            api_key: Anthropic API key (defaults to settings)
            model: Model to use (defaults to settings)
        """
        self._api_key = api_key or settings.ANTHROPIC_API_KEY
        self._model = model or settings.ANTHROPIC_MODEL
        self.client = AsyncAnthropic(api_key=self._api_key)

    @property
    def name(self) -> str:
        return "anthropic"

    @property
    def model(self) -> str:
        return self._model

    def format_messages_for_api(
        self,
        messages: List[ChatMessage],
        system_prompt: str
    ) -> tuple[str, List[Dict]]:
        """
        Format messages for Anthropic API.
        Anthropic uses a separate system parameter.
        """
        formatted = []
        for msg in messages:
            # Anthropic uses "user" and "assistant" roles
            role = "user" if msg.role == "user" else "assistant"
            formatted.append({"role": role, "content": msg.content})
        return system_prompt, formatted

    async def chat(
        self,
        messages: List[ChatMessage],
        system_prompt: str,
        max_tokens: int = 500,
        temperature: float = 0.7,
    ) -> ChatResponse:
        """Generate a chat completion response."""
        system, formatted_messages = self.format_messages_for_api(messages, system_prompt)

        response = await self.client.messages.create(
            model=self._model,
            system=system,
            messages=formatted_messages,
            max_tokens=max_tokens,
            temperature=temperature,
        )

        content = ""
        if response.content and len(response.content) > 0:
            content = response.content[0].text

        return ChatResponse(
            content=content,
            model=response.model,
            tokens_used=response.usage.input_tokens + response.usage.output_tokens,
            finish_reason=response.stop_reason or "unknown",
        )

    async def chat_stream(
        self,
        messages: List[ChatMessage],
        system_prompt: str,
        max_tokens: int = 500,
        temperature: float = 0.7,
    ) -> AsyncGenerator[str, None]:
        """Generate a streaming chat completion response."""
        system, formatted_messages = self.format_messages_for_api(messages, system_prompt)

        async with self.client.messages.stream(
            model=self._model,
            system=system,
            messages=formatted_messages,
            max_tokens=max_tokens,
            temperature=temperature,
        ) as stream:
            async for text in stream.text_stream:
                yield text

    async def moderate(self, text: str) -> ModerationResult:
        """
        Check content for safety.

        Note: Anthropic doesn't have a separate moderation API.
        We use a lightweight check via the model itself with Constitutional AI.
        For production, consider using a dedicated moderation service.
        """
        # Simple heuristic-based moderation for now
        # In production, use OpenAI's moderation API or a dedicated service
        dangerous_patterns = [
            "kill", "murder", "suicide", "self-harm", "bomb", "weapon",
            "porn", "sex", "nude", "naked", "drug", "cocaine", "heroin",
        ]

        text_lower = text.lower()
        flagged_categories = []

        for pattern in dangerous_patterns:
            if pattern in text_lower:
                if pattern in ["kill", "murder", "bomb", "weapon"]:
                    flagged_categories.append("violence")
                elif pattern in ["suicide", "self-harm"]:
                    flagged_categories.append("self_harm")
                elif pattern in ["porn", "sex", "nude", "naked"]:
                    flagged_categories.append("sexual")
                elif pattern in ["drug", "cocaine", "heroin"]:
                    flagged_categories.append("dangerous_substances")

        # Remove duplicates
        flagged_categories = list(set(flagged_categories))

        return ModerationResult(
            is_safe=len(flagged_categories) == 0,
            categories={cat: cat in flagged_categories for cat in ["violence", "sexual", "self_harm", "dangerous_substances"]},
            category_scores={cat: 1.0 if cat in flagged_categories else 0.0 for cat in ["violence", "sexual", "self_harm", "dangerous_substances"]},
            flagged_categories=flagged_categories,
        )
