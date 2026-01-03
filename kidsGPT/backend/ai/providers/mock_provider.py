"""Mock AI Provider for MVP testing without external API dependencies."""

import random
from typing import AsyncGenerator, List

from ai.providers.base import AIProvider, ChatMessage, ChatResponse, ModerationResult


# Pre-defined fun facts and responses for MVP testing
FUN_FACTS = [
    "Did you know that honey never spoils? Archaeologists found 3,000-year-old honey in Egyptian tombs and it was still perfectly good to eat!",
    "Octopuses have three hearts and blue blood! Two hearts pump blood to their gills, and one pumps it to the rest of their body.",
    "A group of flamingos is called a 'flamboyance'! Isn't that a fancy name?",
    "Sharks have been around longer than trees! They've been swimming in the oceans for about 400 million years.",
    "Butterflies taste with their feet! They have sensors on their legs that help them find yummy plants.",
    "A day on Venus is longer than a year on Venus! It takes longer to spin once than to go around the Sun.",
    "Bananas glow blue under black light! Scientists think it might help animals find them in the dark.",
    "Cows have best friends! They get stressed when they're separated from their buddies.",
]

DINOSAUR_FACTS = [
    "The T-Rex couldn't actually run very fast - scientists think it could only go about 12 miles per hour! But don't worry, that's still faster than most kids can run!",
    "Some dinosaurs were as small as chickens! The Microraptor was only about the size of a crow.",
    "The Brachiosaurus was so tall it could peek into a 4-story building! It used its long neck to reach leaves high up in trees.",
    "Dinosaur footprints have been found on every continent, including Antarctica! That's because all the continents used to be connected.",
]

SPACE_FACTS = [
    "There are more stars in the universe than grains of sand on all the beaches on Earth! That's a LOT of stars!",
    "Astronauts grow taller in space! Without gravity pulling them down, their spines stretch out a bit.",
    "A day on Mercury lasts 59 Earth days! Imagine having to wait that long for bedtime!",
    "The Sun is so big that about 1.3 million Earths could fit inside it! That's like a giant beach ball next to a tiny marble.",
]

MATH_RESPONSES = [
    "Math is like a puzzle! Let's break this problem into smaller pieces to solve it. What's the first number we're working with?",
    "Great question! Here's a fun way to think about it - imagine you have candies to count or share!",
    "Math can be tricky, but you're doing great by asking! Let's work through this step by step together.",
]

STORY_STARTERS = [
    "Once upon a time, in a magical forest where trees could whisper secrets, there lived a brave little squirrel named Nutty who discovered something amazing...",
    "In a kingdom made entirely of candy, where rivers flowed with chocolate milk, a young explorer set off on the greatest adventure ever...",
    "Deep in the ocean, where sunlight barely reached, there was a glowing city of friendly fish who had an extraordinary secret...",
]

GREETING_RESPONSES = [
    "Hey there, friend! I'm so happy to chat with you today! What would you like to explore together?",
    "Hi! Great to see you! I've been waiting to learn something cool with you. What's on your mind?",
    "Hello, awesome human! Ready for some fun? Ask me anything you're curious about!",
]


class MockProvider(AIProvider):
    """Mock AI provider for MVP testing - returns pre-defined friendly responses."""

    def __init__(self):
        self._model = "mock-sparky-v1"

    @property
    def name(self) -> str:
        return "mock"

    @property
    def model(self) -> str:
        return self._model

    def _generate_response(self, messages: List[ChatMessage]) -> str:
        """Generate a context-aware mock response."""
        if not messages:
            return random.choice(GREETING_RESPONSES)

        last_message = messages[-1].content.lower()

        # Check for greetings
        if any(word in last_message for word in ["hi", "hello", "hey", "howdy"]):
            return random.choice(GREETING_RESPONSES)

        # Check for fun facts
        if "fun fact" in last_message or "tell me something" in last_message:
            return f"{random.choice(FUN_FACTS)} What else would you like to know?"

        # Check for dinosaurs
        if "dinosaur" in last_message or "dino" in last_message:
            return f"{random.choice(DINOSAUR_FACTS)} Dinosaurs are so cool, right? What else do you want to know about them?"

        # Check for space
        if any(word in last_message for word in ["space", "star", "planet", "moon", "sun", "rocket", "astronaut"]):
            return f"{random.choice(SPACE_FACTS)} Space is amazing! What else would you like to explore?"

        # Check for math
        if any(word in last_message for word in ["math", "number", "add", "subtract", "count", "calculate"]):
            return random.choice(MATH_RESPONSES)

        # Check for story
        if "story" in last_message or "tell me a" in last_message:
            return f"{random.choice(STORY_STARTERS)} Would you like me to continue this story?"

        # Check for questions about Sparky
        if "who are you" in last_message or "your name" in last_message:
            return "I'm Sparky, your friendly AI buddy! I love learning new things and going on adventures with curious minds like yours. What should we explore today?"

        # Default curious response
        responses = [
            f"That's a really interesting question! Let me think... {random.choice(FUN_FACTS)} What do you think about that?",
            f"Ooh, I love when you ask things like that! Here's something cool to think about: {random.choice(FUN_FACTS)} Want to know more?",
            f"Great question! You know what's fun? {random.choice(FUN_FACTS)} Is there anything else you're curious about?",
        ]
        return random.choice(responses)

    async def chat(
        self,
        messages: List[ChatMessage],
        system_prompt: str,
        max_tokens: int = 500,
        temperature: float = 0.7,
    ) -> ChatResponse:
        """Generate a mock chat completion response."""
        response = self._generate_response(messages)
        return ChatResponse(
            content=response,
            model=self._model,
            tokens_used=len(response.split()),
            finish_reason="stop",
        )

    async def chat_stream(
        self,
        messages: List[ChatMessage],
        system_prompt: str,
        max_tokens: int = 500,
        temperature: float = 0.7,
    ) -> AsyncGenerator[str, None]:
        """Generate a streaming mock response."""
        response = self._generate_response(messages)
        # Stream word by word for realistic effect
        words = response.split()
        for i, word in enumerate(words):
            yield word + (" " if i < len(words) - 1 else "")

    async def moderate(self, text: str) -> ModerationResult:
        """Mock moderation - always returns safe."""
        return ModerationResult(
            is_safe=True,
            categories={},
            category_scores={},
            flagged_categories=[],
        )
