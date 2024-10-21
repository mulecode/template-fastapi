"""
Data model for health check response.
"""

from pydantic import BaseModel


class HealthV1Response(BaseModel):
    """
    Health check response model.
    """

    status: str = "OK"
