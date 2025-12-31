"""
Tests for children profile endpoints.
"""

import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_create_child(client: AsyncClient, test_user: dict):
    """Test creating a child profile."""
    response = await client.post(
        f"/api/children/?parent_id={test_user['id']}",
        json={
            "name": "Alex",
            "age": 7,
            "interests": ["dinosaurs", "space"]
        }
    )

    assert response.status_code == 201
    data = response.json()
    assert data["name"] == "Alex"
    assert data["age"] == 7
    assert data["parent_id"] == test_user["id"]
    assert data["interests"] == ["dinosaurs", "space"]
    assert data["daily_message_limit"] == 50
    assert data["messages_today"] == 0


@pytest.mark.asyncio
async def test_create_child_invalid_age(client: AsyncClient, test_user: dict):
    """Test that child age must be 3-13."""
    # Too young
    response = await client.post(
        f"/api/children/?parent_id={test_user['id']}",
        json={"name": "Baby", "age": 2}
    )
    assert response.status_code == 422

    # Too old
    response = await client.post(
        f"/api/children/?parent_id={test_user['id']}",
        json={"name": "Teen", "age": 14}
    )
    assert response.status_code == 422


@pytest.mark.asyncio
async def test_list_children(client: AsyncClient, test_user: dict, test_child: dict):
    """Test listing children for a parent."""
    response = await client.get(f"/api/children/?parent_id={test_user['id']}")

    assert response.status_code == 200
    data = response.json()
    assert len(data) == 1
    assert data[0]["name"] == test_child["name"]
    assert "total_conversations" in data[0]
    assert "can_send_message" in data[0]


@pytest.mark.asyncio
async def test_get_child(client: AsyncClient, test_user: dict, test_child: dict):
    """Test getting a specific child profile."""
    response = await client.get(
        f"/api/children/{test_child['id']}?parent_id={test_user['id']}"
    )

    assert response.status_code == 200
    data = response.json()
    assert data["id"] == test_child["id"]
    assert data["name"] == test_child["name"]


@pytest.mark.asyncio
async def test_get_child_wrong_parent(client: AsyncClient, test_child: dict):
    """Test that parents can't access other parents' children."""
    response = await client.get(f"/api/children/{test_child['id']}?parent_id=999")
    assert response.status_code == 404


@pytest.mark.asyncio
async def test_update_child(client: AsyncClient, test_user: dict, test_child: dict):
    """Test updating a child profile."""
    response = await client.patch(
        f"/api/children/{test_child['id']}?parent_id={test_user['id']}",
        json={"name": "Updated Name", "age": 9}
    )

    assert response.status_code == 200
    data = response.json()
    assert data["name"] == "Updated Name"
    assert data["age"] == 9


@pytest.mark.asyncio
async def test_delete_child(client: AsyncClient, test_user: dict, test_child: dict):
    """Test deleting a child profile (soft delete)."""
    response = await client.delete(
        f"/api/children/{test_child['id']}?parent_id={test_user['id']}"
    )

    assert response.status_code == 204

    # Verify child is no longer accessible
    response = await client.get(
        f"/api/children/{test_child['id']}?parent_id={test_user['id']}"
    )
    assert response.status_code == 404
