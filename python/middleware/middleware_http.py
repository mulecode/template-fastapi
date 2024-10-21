"""
module to register fastapi intercepts
"""

import time

from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request


class ResponseTimeHeaderMiddleware(BaseHTTPMiddleware):
    """
    Middleware to calculate the time taken to process a request
    """

    async def dispatch(self, request: Request, call_next):
        """
        Calculate the time taken to process a request
        :param request:
        :param call_next:
        :return:
        """
        start_time = time.perf_counter()
        response = await call_next(request)
        process_time = time.perf_counter() - start_time
        response.headers["X-Process-Time"] = str(process_time)
        return response
