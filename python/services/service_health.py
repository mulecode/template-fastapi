"""
Module for health check service
"""

from data.data_health import HealthV1Response


async def health_check() -> HealthV1Response:
    """
    Health check service
    @return: HealthV1Response
    """
    return HealthV1Response(status="OK")
