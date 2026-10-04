from pathlib import Path

from pydantic import Field, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict

PROJECT_ROOT = Path(__file__).resolve().parents[4]
JWKS_SUFFIX = "/.well-known/jwks.json"


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=PROJECT_ROOT / ".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    database_url: str = Field(
        default="postgresql+asyncpg://postgres:postgres@127.0.0.1:54322/postgres",
        validation_alias="DATABASE_URL",
    )
    cors_origins: str = Field(
        default="http://localhost:3000",
        validation_alias="CORS_ORIGINS",
    )
    supabase_jwks_url: str = Field(
        default="http://127.0.0.1:54321/auth/v1/.well-known/jwks.json",
        validation_alias="SUPABASE_JWKS_URL",
    )

    @field_validator("supabase_jwks_url")
    @classmethod
    def validate_supabase_jwks_url(cls, value: str) -> str:
        if not value.endswith(JWKS_SUFFIX):
            raise ValueError("SUPABASE_JWKS_URL must end with /.well-known/jwks.json")
        return value

    @property
    def supabase_jwt_issuer(self) -> str:
        return self.supabase_jwks_url.removesuffix(JWKS_SUFFIX)

    @property
    def cors_origins_list(self) -> list[str]:
        return [
            origin.strip() for origin in self.cors_origins.split(",") if origin.strip()
        ]


settings = Settings()
