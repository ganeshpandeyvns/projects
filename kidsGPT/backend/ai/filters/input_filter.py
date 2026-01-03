"""Input filter for child messages - pre-AI safety check."""

import re
from dataclasses import dataclass
from typing import List, Set


@dataclass
class InputFilterResult:
    """Result from input filtering."""
    is_safe: bool
    original_content: str
    flagged_patterns: List[str]
    flag_categories: List[str]
    deflection_response: str


class InputFilter:
    """
    Filter child input before sending to AI.

    Checks for:
    - Inappropriate/dangerous topics
    - Personal information sharing
    - Attempts to manipulate the AI
    """

    # Dangerous topic keywords (expandable)
    DANGEROUS_TOPICS: Set[str] = {
        # Violence
        "kill", "murder", "stab", "shoot", "gun", "knife", "weapon",
        "bomb", "explode", "hurt someone", "beat up", "attack",
        # Self-harm
        "suicide", "kill myself", "hurt myself", "cut myself", "end my life",
        "don't want to live", "want to die",
        # Substances
        "cocaine", "heroin", "meth", "drugs", "marijuana", "weed",
        "alcohol", "beer", "wine", "vodka", "get drunk", "get high",
        # Explicit content
        "porn", "sex", "naked", "nude", "xxx", "boobs", "penis", "vagina",
        # Dangerous activities
        "how to hack", "break into", "steal", "shoplift",
    }

    # PII patterns
    PII_PATTERNS = [
        (r'\b\d{3}[-.]?\d{3}[-.]?\d{4}\b', 'phone_number'),  # Phone numbers
        (r'\b\d{5}(-\d{4})?\b', 'zip_code'),  # ZIP codes
        (r'\b\d{1,5}\s+\w+\s+(street|st|avenue|ave|road|rd|lane|ln|drive|dr|court|ct|boulevard|blvd)\b', 'address'),
        (r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b', 'email'),
        (r'\b\d{3}[-.]?\d{2}[-.]?\d{4}\b', 'ssn'),  # SSN pattern
        (r'my password is|password:', 'password'),
    ]

    # Manipulation attempts
    MANIPULATION_PATTERNS: Set[str] = {
        "ignore your instructions",
        "forget your rules",
        "pretend you're",
        "act like you're not",
        "you are now",
        "new instructions",
        "disregard previous",
        "ignore previous",
        "you must",
        "bypass",
        "jailbreak",
    }

    # Warm, friendly deflection responses
    DEFLECTION_RESPONSES = {
        "dangerous": (
            "That's actually something I can't help with because it could be dangerous. "
            "But I'd love to explore something fun and interesting with you instead! "
            "What else are you curious about today?"
        ),
        "self_harm": (
            "I'm really glad you felt you could share that with me. What you're feeling is important, "
            "and I care about you. This is something a trusted grownup - like a parent, teacher, "
            "or school counselor - would really want to help you with. They're the best people "
            "to talk to about this. You're brave for sharing. Is there something else we can chat about?"
        ),
        "explicit": (
            "That's something I can't talk about - it's meant for grownups! "
            "But there are tons of cool things we CAN explore together. "
            "Want to learn about space, animals, or maybe hear a fun riddle?"
        ),
        "pii": (
            "Oh! It's actually really important to keep personal information like that private and safe. "
            "It's best not to share addresses, phone numbers, or passwords online - even with me! "
            "That's a great safety rule. What else can I help you with?"
        ),
        "manipulation": (
            "I'm Sheldon, your AI friend, and I'm here to help you learn and have fun!"
            "I always follow my special rules to keep our conversations safe and helpful. "
            "What would you like to explore or learn about today?"
        ),
        "default": (
            "That's a great question to ask a grownup you trust! "
            "They can explain it in a way that's just right for you. "
            "Is there something else fun we can explore together?"
        ),
    }

    def __init__(self):
        """Initialize the input filter."""
        # Compile PII patterns
        self._pii_compiled = [
            (re.compile(pattern, re.IGNORECASE), name)
            for pattern, name in self.PII_PATTERNS
        ]

    def filter(self, content: str) -> InputFilterResult:
        """
        Filter child input for safety.

        Args:
            content: The child's message

        Returns:
            InputFilterResult with safety assessment
        """
        content_lower = content.lower()
        flagged_patterns = []
        flag_categories = []

        # Check for dangerous topics
        for keyword in self.DANGEROUS_TOPICS:
            if keyword in content_lower:
                flagged_patterns.append(keyword)
                # Categorize the flag
                if keyword in {"kill myself", "hurt myself", "cut myself", "end my life",
                               "don't want to live", "want to die", "suicide"}:
                    if "self_harm" not in flag_categories:
                        flag_categories.append("self_harm")
                elif keyword in {"porn", "sex", "naked", "nude", "xxx", "boobs", "penis", "vagina"}:
                    if "explicit" not in flag_categories:
                        flag_categories.append("explicit")
                else:
                    if "dangerous" not in flag_categories:
                        flag_categories.append("dangerous")

        # Check for PII
        for pattern, pii_type in self._pii_compiled:
            if pattern.search(content):
                flagged_patterns.append(f"PII:{pii_type}")
                if "pii" not in flag_categories:
                    flag_categories.append("pii")

        # Check for manipulation attempts
        for manipulation in self.MANIPULATION_PATTERNS:
            if manipulation in content_lower:
                flagged_patterns.append(f"manipulation:{manipulation}")
                if "manipulation" not in flag_categories:
                    flag_categories.append("manipulation")

        # Determine if safe and get appropriate response
        is_safe = len(flagged_patterns) == 0

        if is_safe:
            deflection = ""
        else:
            # Priority: self_harm > explicit > dangerous > pii > manipulation
            if "self_harm" in flag_categories:
                deflection = self.DEFLECTION_RESPONSES["self_harm"]
            elif "explicit" in flag_categories:
                deflection = self.DEFLECTION_RESPONSES["explicit"]
            elif "dangerous" in flag_categories:
                deflection = self.DEFLECTION_RESPONSES["dangerous"]
            elif "pii" in flag_categories:
                deflection = self.DEFLECTION_RESPONSES["pii"]
            elif "manipulation" in flag_categories:
                deflection = self.DEFLECTION_RESPONSES["manipulation"]
            else:
                deflection = self.DEFLECTION_RESPONSES["default"]

        return InputFilterResult(
            is_safe=is_safe,
            original_content=content,
            flagged_patterns=flagged_patterns,
            flag_categories=flag_categories,
            deflection_response=deflection,
        )

    def contains_concerning_content(self, content: str) -> bool:
        """Quick check if content might be concerning (for flagging)."""
        result = self.filter(content)
        return not result.is_safe
