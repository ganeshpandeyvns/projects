"""
Tests for chat endpoints.
Note: These tests mock the AI service to avoid actual API calls.
"""

import pytest
from unittest.mock import AsyncMock, patch, MagicMock
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_get_today_stats(client: AsyncClient, test_child: dict):
    """Test getting today's chat stats for a child."""
    response = await client.get(f"/api/chat/today/{test_child['id']}")

    assert response.status_code == 200
    data = response.json()
    assert data["child_id"] == test_child["id"]
    assert data["child_name"] == test_child["name"]
    assert data["messages_sent_today"] == 0
    assert data["daily_limit"] == 50
    assert data["messages_remaining"] == 50
    assert data["can_send_message"] is True


@pytest.mark.asyncio
async def test_send_message(client: AsyncClient, test_child: dict):
    """Test sending a chat message."""
    # Mock the AI service to avoid actual API calls
    mock_ai_response = MagicMock()
    mock_ai_response.content = "That's a great question! Let me explain..."
    mock_ai_response.model = "test-model"
    mock_ai_response.tokens_used = 100

    with patch("app.routers.chat.get_ai_service") as mock_get_ai:
        mock_service = AsyncMock()
        mock_service.chat.return_value = mock_ai_response
        mock_get_ai.return_value = mock_service

        response = await client.post(
            "/api/chat/",
            json={
                "child_id": test_child["id"],
                "message": "Why is the sky blue?"
            }
        )

    assert response.status_code == 200
    data = response.json()
    assert "conversation_id" in data
    assert data["message"]["content"] == "Why is the sky blue?"
    assert data["message"]["role"] == "child"
    assert data["response"]["role"] == "assistant"
    assert data["messages_remaining_today"] == 49


@pytest.mark.asyncio
async def test_message_limit_enforcement(client: AsyncClient, test_user: dict):
    """Test that daily message limit is enforced."""
    # Create a child with 1 message limit
    response = await client.post(
        f"/api/children/?parent_id={test_user['id']}",
        json={
            "name": "LimitedKid",
            "age": 8,
            "daily_message_limit": 1
        }
    )
    child = response.json()

    # Mock AI service
    mock_ai_response = MagicMock()
    mock_ai_response.content = "Hello!"
    mock_ai_response.model = "test-model"
    mock_ai_response.tokens_used = 50

    # Send first message (should succeed)
    with patch("app.routers.chat.get_ai_service") as mock_get_ai:
        mock_service = AsyncMock()
        mock_service.chat.return_value = mock_ai_response
        mock_get_ai.return_value = mock_service

        response = await client.post(
            "/api/chat/",
            json={"child_id": child["id"], "message": "Hi!"}
        )
        assert response.status_code == 200

    # Send second message (should fail - limit reached)
    response = await client.post(
        "/api/chat/",
        json={"child_id": child["id"], "message": "Hi again!"}
    )
    assert response.status_code == 429


@pytest.mark.asyncio
async def test_get_conversations(client: AsyncClient, test_user: dict, test_child: dict):
    """Test getting conversation history for a child."""
    # First send a message to create a conversation
    mock_ai_response = MagicMock()
    mock_ai_response.content = "Hello there!"
    mock_ai_response.model = "test-model"
    mock_ai_response.tokens_used = 50

    with patch("app.routers.chat.get_ai_service") as mock_get_ai:
        mock_service = AsyncMock()
        mock_service.chat.return_value = mock_ai_response
        mock_get_ai.return_value = mock_service

        await client.post(
            "/api/chat/",
            json={"child_id": test_child["id"], "message": "Hello!"}
        )

    # Now get conversations
    response = await client.get(
        f"/api/chat/conversations/{test_child['id']}?parent_id={test_user['id']}"
    )

    assert response.status_code == 200
    data = response.json()
    assert len(data) >= 1
    assert "title" in data[0]
    assert "message_count" in data[0]


@pytest.mark.asyncio
async def test_get_conversation_detail(client: AsyncClient, test_user: dict, test_child: dict):
    """Test getting a specific conversation with messages."""
    # Create a conversation
    mock_ai_response = MagicMock()
    mock_ai_response.content = "I'm here to help!"
    mock_ai_response.model = "test-model"
    mock_ai_response.tokens_used = 50

    with patch("app.routers.chat.get_ai_service") as mock_get_ai:
        mock_service = AsyncMock()
        mock_service.chat.return_value = mock_ai_response
        mock_get_ai.return_value = mock_service

        chat_response = await client.post(
            "/api/chat/",
            json={"child_id": test_child["id"], "message": "Hello Sparky!"}
        )
        conv_id = chat_response.json()["conversation_id"]

    # Get conversation detail
    response = await client.get(
        f"/api/chat/conversation/{conv_id}?parent_id={test_user['id']}"
    )

    assert response.status_code == 200
    data = response.json()
    assert data["id"] == conv_id
    assert "messages" in data
    assert len(data["messages"]) >= 2  # At least child message + assistant response


@pytest.mark.asyncio
async def test_nonexistent_child(client: AsyncClient):
    """Test sending message for non-existent child."""
    response = await client.post(
        "/api/chat/",
        json={"child_id": 9999, "message": "Hello!"}
    )
    assert response.status_code == 404


@pytest.mark.asyncio
async def test_conversation_not_found(client: AsyncClient, test_user: dict):
    """Test getting non-existent conversation."""
    response = await client.get(
        f"/api/chat/conversation/9999?parent_id={test_user['id']}"
    )
    assert response.status_code == 404
