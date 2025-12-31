"""
Tests for authentication endpoints.
"""

import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_register_user(client: AsyncClient):
    """Test user registration."""
    response = await client.post("/api/auth/register", json={
        "email": "newuser@test.com",
        "display_name": "New User"
    })

    assert response.status_code == 201
    data = response.json()
    assert data["email"] == "newuser@test.com"
    assert data["display_name"] == "New User"
    assert data["role"] == "parent"
    assert data["subscription_tier"] == "free"
    assert data["is_active"] is True
    assert "id" in data


@pytest.mark.asyncio
async def test_register_duplicate_email(client: AsyncClient, test_user: dict):
    """Test that duplicate email registration fails."""
    response = await client.post("/api/auth/register", json={
        "email": "parent@test.com",  # Same as test_user
        "display_name": "Another User"
    })

    assert response.status_code == 400
    assert "already registered" in response.json()["detail"].lower()


@pytest.mark.asyncio
async def test_login_existing_user(client: AsyncClient, test_user: dict):
    """Test login with existing user."""
    response = await client.post(f"/api/auth/login?email={test_user['email']}")

    assert response.status_code == 200
    data = response.json()
    assert data["email"] == test_user["email"]
    assert data["id"] == test_user["id"]


@pytest.mark.asyncio
async def test_login_nonexistent_user(client: AsyncClient):
    """Test login with non-existent user fails."""
    response = await client.post("/api/auth/login?email=nobody@test.com")

    assert response.status_code == 404


@pytest.mark.asyncio
async def test_get_me(client: AsyncClient, test_user: dict):
    """Test get current user info."""
    response = await client.get(f"/api/auth/me?user_id={test_user['id']}")

    assert response.status_code == 200
    data = response.json()
    assert data["email"] == test_user["email"]
