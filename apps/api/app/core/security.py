from typing import Any

import jwt


def decode_jwt(token: str, key: str) -> dict[str, Any]:
    return jwt.decode(token, key, algorithms=["HS256"])
