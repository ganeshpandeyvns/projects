"""
Pytest fixtures and configuration for KidsGPT backend tests.
"""

import os
import pytest
import asyncio
from typing import AsyncGenerator

# Set test environment before importing app modules
os.environ["TESTING"] = "1"
os.environ["DATABASE_URL"] = "sqlite+aiosqlite:///:memory:"

from httpx import AsyncClient, ASGITransport
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker

from app.main import app
from app.core.database import Base, get_db


# Create test engine
test_engine = create_async_engine(
    "sqlite+aiosqlite:///:memory:",
    echo=False,
)

TestSessionLocal = async_sessionmaker(
    bind=test_engine,
    class_=AsyncSession,
    expire_on_commit=False,
    autocommit=False,
    autoflush=False,
)


@pytest.fixture(scope="session")
def event_loop():
    """Create an event loop for the test session."""
    loop = asyncio.get_event_loop_policy().new_event_loop()
    yield loop
    loop.close()


@pytest.fixture(scope="function")
async def db_session() -> AsyncGenerator[AsyncSession, None]:
    """Create a fresh database session for each test."""
    async with test_engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    async with TestSessionLocal() as session:
        yield session

    async with test_engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)


@pytest.fixture(scope="function")
async def client(db_session: AsyncSession) -> AsyncGenerator[AsyncClient, None]:
    """Create an async HTTP client for testing."""

    async def override_get_db():
        yield db_session

    app.dependency_overrides[get_db] = override_get_db

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        yield ac

    app.dependency_overrides.clear()


@pytest.fixture
async def test_user(client: AsyncClient) -> dict:
    """Create a test user for tests that need authentication."""
    response = await client.post("/api/auth/register", json={
        "email": "parent@test.com",
        "display_name": "Test Parent"
    })
    return response.json()


@pytest.fixture
async def test_child(client: AsyncClient, test_user: dict) -> dict:
    """Create a test child profile."""
    response = await client.post(
        f"/api/children/?parent_id={test_user['id']}",
        json={
            "name": "TestKid",
            "age": 8,
            "interests": ["dinosaurs", "space"]
        }
    )
    return response.json()
