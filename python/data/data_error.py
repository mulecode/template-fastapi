"""
Data model for health check response.
"""

from pydantic import BaseModel


class ApplicationErrorV1Response(BaseModel):
    """
    Application error response model.
    """

    statusCode: int
    message: str
