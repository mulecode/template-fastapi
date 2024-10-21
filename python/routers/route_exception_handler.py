"""
Main module for fast api routes
"""

from fastapi import APIRouter
from fastapi import Request, FastAPI
from fastapi.responses import JSONResponse

from data.data_error import ApplicationErrorV1Response

router = APIRouter()


def register_exception_handlers(app: FastAPI):
    """
    Register the exception handlers
    :param app:
    :return:
    """

    @app.exception_handler(Exception)
    async def http_exception_handler(request: Request, exc: Exception):
        """
        Default exception handler
        :param request:
        :param exc:
        :return:
        """
        error_response = ApplicationErrorV1Response(
            statusCode=500,
            message="Oops! Something went wrong.",
        )
        return JSONResponse(status_code=500, content=error_response.model_dump())
