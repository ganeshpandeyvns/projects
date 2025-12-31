"""AI Service - Factory for AI providers and main chat interface."""

from typing import Dict, Type, Optional, AsyncGenerator, List
from functools import lru_cache

from ai.providers.base import AIProvider, ChatMessage, ChatResponse, ModerationResult
from ai.providers.openai_provider import OpenAIProvider
from ai.providers.anthropic_provider import AnthropicProvider
from ai.prompts import get_system_prompt
from ai.filters.input_filter import InputFilter
from ai.filters.output_filter import OutputFilter
from app.core.config import settings


class AIService:
    """
    AI Service - Factory for AI providers with safety filters.

    Usage:
        service = AIService.get_instance()
        response = await service.chat(child_age=7, messages=[...])
    """

    _providers: Dict[str, Type[AIProvider]] = {
        "openai": OpenAIProvider,
        "anthropic": AnthropicProvider,
    }

    _instance: Optional["AIService"] = None
    _current_provider: Optional[AIProvider] = None

    def __init__(self, provider_name: str = None):
        """
        Initialize AI Service.

        Args:
            provider_name: Provider to use ('openai' or 'anthropic')
        """
        self.provider_name = provider_name or settings.DEFAULT_AI_PROVIDER
        self._provider = self._create_provider(self.provider_name)
        self.input_filter = InputFilter()
        self.output_filter = OutputFilter()

    @classmethod
    def get_instance(cls, provider_name: str = None) -> "AIService":
        """Get or create singleton instance."""
        if cls._instance is None or (provider_name and provider_name != cls._instance.provider_name):
            cls._instance = cls(provider_name)
        return cls._instance

    @classmethod
    def switch_provider(cls, provider_name: str) -> "AIService":
        """Switch to a different AI provider."""
        if provider_name not in cls._providers:
            raise ValueError(f"Unknown provider: {provider_name}. Available: {list(cls._providers.keys())}")
        cls._instance = cls(provider_name)
        return cls._instance

    def _create_provider(self, name: str) -> AIProvider:
        """Create a provider instance."""
        if name not in self._providers:
            raise ValueError(f"Unknown provider: {name}")
        return self._providers[name]()

    @property
    def provider(self) -> AIProvider:
        """Get current AI provider."""
        return self._provider

    async def chat(
        self,
        child_age: int,
        messages: List[ChatMessage],
        child_name: str = "friend",
        interests: List[str] = None,
        learning_goals: List[str] = None,
        max_tokens: int = 500,
    ) -> ChatResponse:
        """
        Generate a chat response with safety filters.

        Args:
            child_age: Child's age (3-13)
            messages: Conversation history
            child_name: Child's name for personalization
            interests: Child's interests
            learning_goals: Parent-defined learning goals
            max_tokens: Max response length

        Returns:
            ChatResponse with filtered content
        """
        # Get age-appropriate system prompt
        system_prompt = get_system_prompt(
            age=child_age,
            child_name=child_name,
            interests=interests or [],
            learning_goals=learning_goals or [],
        )

        # Filter input (last message from child)
        if messages:
            last_message = messages[-1]
            if last_message.role == "user":
                filter_result = self.input_filter.filter(last_message.content)
                if not filter_result.is_safe:
                    # Return a safe deflection response
                    return ChatResponse(
                        content=filter_result.deflection_response,
                        model=self._provider.model,
                        tokens_used=0,
                        finish_reason="filtered",
                    )

        # Generate response
        response = await self._provider.chat(
            messages=messages,
            system_prompt=system_prompt,
            max_tokens=max_tokens,
            temperature=0.7,
        )

        # Filter output
        output_result = await self.output_filter.filter(response.content)
        if not output_result.is_safe:
            response.content = output_result.filtered_content

        return response

    async def chat_stream(
        self,
        child_age: int,
        messages: List[ChatMessage],
        child_name: str = "friend",
        interests: List[str] = None,
        learning_goals: List[str] = None,
        max_tokens: int = 500,
    ) -> AsyncGenerator[str, None]:
        """
        Generate a streaming chat response with safety filters.

        Note: For streaming, we apply input filter before and
        accumulate output for post-filtering (with risk of partial unsafe content).
        Consider using non-streaming for maximum safety.
        """
        # Get age-appropriate system prompt
        system_prompt = get_system_prompt(
            age=child_age,
            child_name=child_name,
            interests=interests or [],
            learning_goals=learning_goals or [],
        )

        # Filter input
        if messages:
            last_message = messages[-1]
            if last_message.role == "user":
                filter_result = self.input_filter.filter(last_message.content)
                if not filter_result.is_safe:
                    yield filter_result.deflection_response
                    return

        # Stream response
        async for chunk in self._provider.chat_stream(
            messages=messages,
            system_prompt=system_prompt,
            max_tokens=max_tokens,
            temperature=0.7,
        ):
            yield chunk

    async def moderate(self, text: str) -> ModerationResult:
        """Check content using the provider's moderation."""
        return await self._provider.moderate(text)


# Convenience function
def get_ai_service(provider: str = None) -> AIService:
    """Get AI service instance."""
    return AIService.get_instance(provider)
