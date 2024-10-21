"""
This is the main file for the FastAPI application.
"""

from fastapi import FastAPI
from fastapi.middleware.gzip import GZipMiddleware

from middleware.middleware_http import ResponseTimeHeaderMiddleware
from routers import route_main
from routers.route_exception_handler import register_exception_handlers

app = FastAPI()
# Register the exception handlers
register_exception_handlers(app)

# Register the main router
app.include_router(route_main.router)

# Register the middlewares (Interceptors)
app.add_middleware(GZipMiddleware, minimum_size=1000, compresslevel=5)
app.add_middleware(ResponseTimeHeaderMiddleware)
