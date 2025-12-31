"""OpenAI provider implementation."""

from typing import AsyncGenerator, List, Dict
from openai import AsyncOpenAI

from ai.providers.base import AIProvider, ChatMessage, ChatResponse, ModerationResult
from app.core.config import settings


class OpenAIProvider(AIProvider):
    """OpenAI GPT provider implementation."""

    def __init__(
        self,
        api_key: str = None,
        model: str = None
    ):
        """
        Initialize OpenAI provider.

        Args:
            api_key: OpenAI API key (defaults to settings)
            model: Model to use (defaults to settings)
        """
        self._api_key = api_key or settings.OPENAI_API_KEY
        self._model = model or settings.OPENAI_MODEL
        self.client = AsyncOpenAI(api_key=self._api_key)

    @property
    def name(self) -> str:
        return "openai"

    @property
    def model(self) -> str:
        return self._model

    async def chat(
        self,
        messages: List[ChatMessage],
        system_prompt: str,
        max_tokens: int = 500,
        temperature: float = 0.7,
    ) -> ChatResponse:
        """Generate a chat completion response."""
        formatted_messages = self.format_messages_for_api(messages, system_prompt)

        response = await self.client.chat.completions.create(
            model=self._model,
            messages=formatted_messages,
            max_tokens=max_tokens,
            temperature=temperature,
        )

        choice = response.choices[0]
        return ChatResponse(
            content=choice.message.content or "",
            model=response.model,
            tokens_used=response.usage.total_tokens if response.usage else 0,
            finish_reason=choice.finish_reason or "unknown",
        )

    async def chat_stream(
        self,
        messages: List[ChatMessage],
        system_prompt: str,
        max_tokens: int = 500,
        temperature: float = 0.7,
    ) -> AsyncGenerator[str, None]:
        """Generate a streaming chat completion response."""
        formatted_messages = self.format_messages_for_api(messages, system_prompt)

        stream = await self.client.chat.completions.create(
            model=self._model,
            messages=formatted_messages,
            max_tokens=max_tokens,
            temperature=temperature,
            stream=True,
        )

        async for chunk in stream:
            if chunk.choices and chunk.choices[0].delta.content:
                yield chunk.choices[0].delta.content

    async def moderate(self, text: str) -> ModerationResult:
        """Check content using OpenAI's moderation API."""
        response = await self.client.moderations.create(input=text)

        result = response.results[0]
        categories = {
            "harassment": result.categories.harassment,
            "harassment_threatening": result.categories.harassment_threatening,
            "hate": result.categories.hate,
            "hate_threatening": result.categories.hate_threatening,
            "self_harm": result.categories.self_harm,
            "self_harm_instructions": result.categories.self_harm_instructions,
            "self_harm_intent": result.categories.self_harm_intent,
            "sexual": result.categories.sexual,
            "sexual_minors": result.categories.sexual_minors,
            "violence": result.categories.violence,
            "violence_graphic": result.categories.violence_graphic,
        }

        category_scores = {
            "harassment": result.category_scores.harassment,
            "harassment_threatening": result.category_scores.harassment_threatening,
            "hate": result.category_scores.hate,
            "hate_threatening": result.category_scores.hate_threatening,
            "self_harm": result.category_scores.self_harm,
            "self_harm_instructions": result.category_scores.self_harm_instructions,
            "self_harm_intent": result.category_scores.self_harm_intent,
            "sexual": result.category_scores.sexual,
            "sexual_minors": result.category_scores.sexual_minors,
            "violence": result.category_scores.violence,
            "violence_graphic": result.category_scores.violence_graphic,
        }

        flagged_categories = [cat for cat, flagged in categories.items() if flagged]

        return ModerationResult(
            is_safe=not result.flagged,
            categories=categories,
            category_scores=category_scores,
            flagged_categories=flagged_categories,
        )
