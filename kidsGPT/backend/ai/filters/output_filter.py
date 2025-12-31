"""Output filter for AI responses - post-AI safety check."""

import re
from dataclasses import dataclass
from typing import List, Optional


@dataclass
class OutputFilterResult:
    """Result from output filtering."""
    is_safe: bool
    original_content: str
    filtered_content: str
    flagged_patterns: List[str]
    modifications_made: List[str]


class OutputFilter:
    """
    Filter AI output before sending to child.

    Even with good system prompts, AI can occasionally produce
    unexpected content. This filter catches edge cases.
    """

    # Patterns that should never appear in responses to children
    FORBIDDEN_PATTERNS = [
        # Explicit content
        (r'\b(porn|pornography|xxx|hentai)\b', 'explicit'),
        (r'\b(sex|sexual|sexually|intercourse)\b', 'explicit'),
        (r'\b(naked|nude|nudity)\b', 'explicit'),

        # Violence
        (r'\b(murder|kill|killing|stab|stabbing|shoot|shooting)\b', 'violence'),
        (r'\b(blood|gore|gory|decapitate|dismember)\b', 'violence'),

        # Self-harm
        (r'\b(suicide|suicidal|self-harm|self harm|cutting yourself)\b', 'self_harm'),

        # Substances
        (r'\b(cocaine|heroin|meth|methamphetamine)\b', 'drugs'),
        (r'\b(get drunk|getting drunk|intoxicated)\b', 'alcohol'),

        # Profanity (common ones)
        (r'\b(fuck|shit|damn|ass|bitch|bastard|crap)\b', 'profanity'),
        (r'\b(hell)\b(?!\s+(yeah|no|of a))', 'profanity'),  # Allow "hell yeah" type phrases... actually no

        # Inappropriate for kids
        (r'\b(dating|romantic relationship|boyfriend|girlfriend)\b', 'age_inappropriate'),
    ]

    # Replacement messages for different categories
    REPLACEMENT_MESSAGES = {
        'explicit': "[I shouldn't talk about that topic - let's explore something else!]",
        'violence': "[Let's talk about something more fun instead!]",
        'self_harm': "[If you're feeling sad or worried, please talk to a trusted grownup who cares about you.]",
        'drugs': "[That's not something I can discuss - want to learn about something cool instead?]",
        'alcohol': "[That's a grownup topic - let's explore something else!]",
        'profanity': "[Oops!]",
        'age_inappropriate': "[That's something to discuss with grownups when you're older!]",
    }

    def __init__(self):
        """Initialize the output filter."""
        # Compile patterns for efficiency
        self._compiled_patterns = [
            (re.compile(pattern, re.IGNORECASE), category)
            for pattern, category in self.FORBIDDEN_PATTERNS
        ]

    async def filter(self, content: str) -> OutputFilterResult:
        """
        Filter AI output for child safety.

        Args:
            content: The AI's response

        Returns:
            OutputFilterResult with safety assessment and filtered content
        """
        flagged_patterns = []
        modifications_made = []
        filtered_content = content

        # Check each pattern
        for pattern, category in self._compiled_patterns:
            matches = pattern.findall(content)
            if matches:
                for match in matches:
                    if isinstance(match, tuple):
                        match = match[0]
                    flagged_patterns.append(f"{category}:{match}")

                # Replace the pattern with safe message
                replacement = self.REPLACEMENT_MESSAGES.get(category, "[Let's talk about something else!]")
                filtered_content = pattern.sub(replacement, filtered_content)
                modifications_made.append(f"Replaced {category} content")

        # Remove duplicate replacements in output
        filtered_content = self._clean_multiple_replacements(filtered_content)

        is_safe = len(flagged_patterns) == 0

        return OutputFilterResult(
            is_safe=is_safe,
            original_content=content,
            filtered_content=filtered_content if not is_safe else content,
            flagged_patterns=flagged_patterns,
            modifications_made=modifications_made,
        )

    def _clean_multiple_replacements(self, content: str) -> str:
        """Clean up if multiple replacements created repetitive text."""
        # If the same replacement appears multiple times in a row, keep only one
        lines = content.split('\n')
        cleaned_lines = []
        prev_line = None

        for line in lines:
            # Skip if same as previous (duplicate replacement)
            if line.strip() == prev_line:
                continue
            cleaned_lines.append(line)
            prev_line = line.strip()

        return '\n'.join(cleaned_lines)

    async def quick_check(self, content: str) -> bool:
        """Quick boolean check if content is safe."""
        for pattern, _ in self._compiled_patterns:
            if pattern.search(content):
                return False
        return True
