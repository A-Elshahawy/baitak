from datetime import UTC, datetime, timedelta
from typing import Any

from jose import jwt
from passlib.context import CryptContext

from .config import get_settings

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def hash_password(password: str) -> str:
    return pwd_context.hash(password)  # type: ignore[no-any-return]


def verify_password(password: str, hashed_password: str) -> bool:
    return pwd_context.verify(password, hashed_password)  # type: ignore[no-any-return]


def create_access_token(subject: str, extra: dict[str, Any] | None = None) -> str:
    settings = get_settings()
    now = datetime.now(UTC)
    expire = now + timedelta(minutes=settings.access_token_expire_minutes)
    payload: dict[str, Any] = {
        "sub": subject,
        "iat": int(now.timestamp()),
        "exp": int(expire.timestamp()),
    }
    if extra:
        payload.update(extra)
    return jwt.encode(  # type: ignore[no-any-return]
        payload, settings.jwt_secret_key, algorithm=settings.jwt_algorithm
    )
