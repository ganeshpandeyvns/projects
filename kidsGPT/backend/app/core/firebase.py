"""Firebase Admin SDK initialization and token verification."""

import logging
from typing import Optional
from dataclasses import dataclass

import firebase_admin
from firebase_admin import auth, credentials

from app.core.config import settings

logger = logging.getLogger(__name__)


@dataclass
class FirebaseUser:
    """Decoded Firebase user info from ID token."""
    uid: str
    email: Optional[str]
    email_verified: bool
    display_name: Optional[str]
    photo_url: Optional[str]


# Global Firebase app instance
_firebase_app: Optional[firebase_admin.App] = None


def init_firebase() -> bool:
    """
    Initialize Firebase Admin SDK.

    Returns True if initialized successfully, False otherwise.
    """
    global _firebase_app

    if _firebase_app is not None:
        return True

    # Check if required config is present
    if not settings.FIREBASE_PROJECT_ID:
        logger.warning("Firebase not configured - FIREBASE_PROJECT_ID is empty")
        return False

    try:
        # Build credentials from environment variables
        if settings.FIREBASE_PRIVATE_KEY and settings.FIREBASE_CLIENT_EMAIL:
            # Use service account credentials from env vars
            cred_dict = {
                "type": "service_account",
                "project_id": settings.FIREBASE_PROJECT_ID,
                "private_key_id": settings.FIREBASE_PRIVATE_KEY_ID,
                "private_key": settings.FIREBASE_PRIVATE_KEY.replace("\\n", "\n"),
                "client_email": settings.FIREBASE_CLIENT_EMAIL,
                "client_id": settings.FIREBASE_CLIENT_ID,
                "auth_uri": "https://accounts.google.com/o/oauth2/auth",
                "token_uri": "https://oauth2.googleapis.com/token",
                "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
                "client_x509_cert_url": f"https://www.googleapis.com/robot/v1/metadata/x509/{settings.FIREBASE_CLIENT_EMAIL.replace('@', '%40')}"
            }
            cred = credentials.Certificate(cred_dict)
        else:
            # Try default credentials (for Google Cloud environments)
            cred = credentials.ApplicationDefault()

        _firebase_app = firebase_admin.initialize_app(cred, {
            "projectId": settings.FIREBASE_PROJECT_ID,
        })
        logger.info(f"Firebase initialized for project: {settings.FIREBASE_PROJECT_ID}")
        return True

    except Exception as e:
        logger.error(f"Failed to initialize Firebase: {e}")
        return False


def verify_id_token(id_token: str) -> Optional[FirebaseUser]:
    """
    Verify a Firebase ID token and extract user info.

    Args:
        id_token: The Firebase ID token from the client

    Returns:
        FirebaseUser if valid, None if invalid
    """
    global _firebase_app

    # Initialize Firebase if not already done
    if _firebase_app is None:
        if not init_firebase():
            logger.error("Cannot verify token - Firebase not initialized")
            return None

    try:
        decoded_token = auth.verify_id_token(id_token)

        return FirebaseUser(
            uid=decoded_token["uid"],
            email=decoded_token.get("email"),
            email_verified=decoded_token.get("email_verified", False),
            display_name=decoded_token.get("name"),
            photo_url=decoded_token.get("picture"),
        )

    except auth.ExpiredIdTokenError:
        logger.warning("Firebase ID token has expired")
        return None
    except auth.RevokedIdTokenError:
        logger.warning("Firebase ID token has been revoked")
        return None
    except auth.InvalidIdTokenError as e:
        logger.warning(f"Invalid Firebase ID token: {e}")
        return None
    except Exception as e:
        logger.error(f"Error verifying Firebase token: {e}")
        return None


def is_firebase_configured() -> bool:
    """Check if Firebase is configured."""
    return bool(settings.FIREBASE_PROJECT_ID)
