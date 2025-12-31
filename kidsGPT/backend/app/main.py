"""KidsGPT FastAPI Application - Safe AI Learning Companion for Children."""

from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
from app.core.database import init_db, close_db
from app.routers import auth, chat, children


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan manager."""
    # Startup
    print(f"Starting {settings.APP_NAME} v{settings.APP_VERSION}")
    await init_db()
    print("Database initialized")
    yield
    # Shutdown
    await close_db()
    print("Database connections closed")


app = FastAPI(
    title=settings.APP_NAME,
    description="Safe AI Learning Companion for Children - API",
    version=settings.APP_VERSION,
    lifespan=lifespan,
)

# CORS middleware for frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:5173",  # Vite dev server
        "http://localhost:3000",  # Alternative dev server
        "http://127.0.0.1:5173",
        "http://127.0.0.1:3000",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Include routers
app.include_router(auth.router, prefix=f"{settings.API_PREFIX}/auth", tags=["Authentication"])
app.include_router(children.router, prefix=f"{settings.API_PREFIX}/children", tags=["Children"])
app.include_router(chat.router, prefix=f"{settings.API_PREFIX}/chat", tags=["Chat"])


@app.get("/")
async def root():
    """Root endpoint - API health check."""
    return {
        "app": settings.APP_NAME,
        "version": settings.APP_VERSION,
        "status": "healthy",
        "message": "Welcome to KidsGPT API - Safe AI for Kids!"
    }


@app.get("/health")
async def health_check():
    """Health check endpoint."""
    return {"status": "healthy"}
