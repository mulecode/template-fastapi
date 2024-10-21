"""
Main module for fast api routes
"""

from fastapi import APIRouter

from data.data_health import HealthV1Response
from services import service_health

router = APIRouter()


@router.get("/api/v1/health", response_model=HealthV1Response)
async def api_v1_health():
    """
    Health check route
    :return: HealthV1Response
    """
    return await service_health.health_check()
