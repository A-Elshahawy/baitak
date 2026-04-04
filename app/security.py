from datetime import UTC, datetime, timedelta
from typing import Any

import bcrypt
from jose import jwt

from .config import get_settings


def hash_password(password: str) -> str:
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()


def verify_password(password: str, hashed_password: str | None) -> bool:
    if hashed_password is None:
        return False
    return bcrypt.checkpw(password.encode(), hashed_password.encode())


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
