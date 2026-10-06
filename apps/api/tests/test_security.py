import json
from datetime import UTC, datetime, timedelta
from typing import Any
from uuid import uuid4

import jwt
import pytest
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.primitives.asymmetric.rsa import RSAPrivateKey
from fastapi import HTTPException
from fastapi.security import HTTPAuthorizationCredentials
from jwt import PyJWKClient

from app.core import security
from app.core.config import settings
from app.core.security import CurrentUser, get_current_user, require_role


@pytest.fixture
def signing_key(monkeypatch: pytest.MonkeyPatch) -> tuple[RSAPrivateKey, str]:
    private_key = rsa.generate_private_key(public_exponent=65537, key_size=2048)
    key_id = uuid4().hex
    public_jwk = json.loads(
        jwt.algorithms.RSAAlgorithm.to_jwk(private_key.public_key())
    )
    public_jwk.update({"kid": key_id, "alg": "RS256", "use": "sig"})
    client = PyJWKClient("https://example.test/jwks.json", cache_keys=True)
    monkeypatch.setattr(client, "fetch_data", lambda: {"keys": [public_jwk]})
    monkeypatch.setattr(security, "jwks_client", client)
    return private_key, key_id


def create_token(
    private_key: RSAPrivateKey,
    key_id: str,
    *,
    user_role: str | None,
    expires_in: timedelta,
    app_metadata_role: str | None = None,
) -> str:
    now = datetime.now(UTC)
    payload: dict[str, Any] = {
        "iss": settings.supabase_jwt_issuer,
        "aud": "authenticated",
        "sub": "user-123",
        "role": "authenticated",
        "iat": now,
        "exp": now + expires_in,
    }
    if user_role is not None:
        payload["user_role"] = user_role
    if app_metadata_role is not None:
        payload["app_metadata"] = {"role": app_metadata_role}

    return jwt.encode(
        payload,
        private_key,
        algorithm="RS256",
        headers={"kid": key_id},
    )


def authorize(token: str) -> CurrentUser:
    credentials = HTTPAuthorizationCredentials(
        scheme="Bearer",
        credentials=token,
    )
    return get_current_user(credentials)


def test_valid_supabase_token_exposes_user_id_and_profile_role_claim(
    signing_key: tuple[RSAPrivateKey, str],
) -> None:
    private_key, key_id = signing_key
    token = create_token(
        private_key,
        key_id,
        user_role="admin",
        expires_in=timedelta(minutes=5),
    )

    user = authorize(token)

    assert user.id == "user-123"
    assert user.role == "admin"


def test_expired_supabase_token_is_rejected(
    signing_key: tuple[RSAPrivateKey, str],
) -> None:
    private_key, key_id = signing_key
    token = create_token(
        private_key,
        key_id,
        user_role="admin",
        expires_in=timedelta(seconds=-1),
    )

    with pytest.raises(HTTPException) as exc_info:
        authorize(token)

    assert exc_info.value.status_code == 401


def test_incorrect_profile_role_is_forbidden(
    signing_key: tuple[RSAPrivateKey, str],
) -> None:
    private_key, key_id = signing_key
    token = create_token(
        private_key,
        key_id,
        user_role="subscriber",
        expires_in=timedelta(minutes=5),
    )
    user = authorize(token)

    with pytest.raises(HTTPException) as exc_info:
        require_role("admin")(current_user=user)

    assert exc_info.value.status_code == 403


def test_app_metadata_role_is_not_used_as_authority(
    signing_key: tuple[RSAPrivateKey, str],
) -> None:
    private_key, key_id = signing_key
    token = create_token(
        private_key,
        key_id,
        user_role=None,
        expires_in=timedelta(minutes=5),
        app_metadata_role="admin",
    )

    with pytest.raises(HTTPException) as exc_info:
        authorize(token)

    assert exc_info.value.status_code == 403
