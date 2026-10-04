from fastapi import APIRouter

from app.modules.platform.schemas import HealthResponse

router = APIRouter(tags=["platform"])


@router.get("/health", response_model=HealthResponse)
async def health_check() -> HealthResponse:
    return HealthResponse()
