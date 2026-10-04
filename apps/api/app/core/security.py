from collections.abc import Callable
from typing import Annotated, Any

import jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jwt import PyJWKClient
from pydantic import BaseModel

from app.core.config import settings

jwks_client = PyJWKClient(settings.supabase_jwks_url, cache_keys=True)
bearer_scheme = HTTPBearer()
ALLOWED_ALGORITHMS = ["ES256", "RS256"]


class CurrentUser(BaseModel):
    id: str
    role: str


def get_current_user(
    credentials: Annotated[HTTPAuthorizationCredentials, Depends(bearer_scheme)],
) -> CurrentUser:
    token = credentials.credentials

    try:
        signing_key = jwks_client.get_signing_key_from_jwt(token)
        payload: dict[str, Any] = jwt.decode(
            token,
            signing_key.key,
            algorithms=ALLOWED_ALGORITHMS,
            audience="authenticated",
            issuer=settings.supabase_jwt_issuer,
            options={"require": ["exp", "iss", "aud", "sub"]},
        )
    except jwt.PyJWKClientConnectionError as exc:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Supabase signing keys are unavailable",
        ) from exc
    except (jwt.InvalidTokenError, jwt.PyJWKClientError) as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid Supabase access token",
            headers={"WWW-Authenticate": "Bearer"},
        ) from exc

    subject = payload.get("sub")
    app_metadata = payload.get("app_metadata")
    role = app_metadata.get("role") if isinstance(app_metadata, dict) else None

    if not isinstance(subject, str) or not subject:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid Supabase access token",
            headers={"WWW-Authenticate": "Bearer"},
        )

    if not isinstance(role, str) or not role:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="A role in app_metadata is required",
        )

    return CurrentUser(id=subject, role=role)


def require_role(required_role: str) -> Callable[..., CurrentUser]:
    def role_dependency(
        current_user: Annotated[CurrentUser, Depends(get_current_user)],
    ) -> CurrentUser:
        if current_user.role != required_role:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Insufficient role",
            )
        return current_user

    return role_dependency
