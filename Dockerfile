#FROM ghcr.io/mulecode/tool-set-amazon-python:1.5.0
FROM python:3.11-alpine

WORKDIR /opt/app

# Ensure Python is available
RUN ln -s /usr/bin/python3 /usr/bin/python

# Copy application files
COPY python/ /opt/app/python/
COPY pyproject.toml /opt/app/

RUN apk update && \
    apk upgrade && \
    apk add --no-cache make=4.4.1-r2 && \
    rm -rf /var/cache/apk/*

# Install dependencies from pyproject.toml using pip
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir .

# Default PROD configuration
ENTRYPOINT ["python", "-m", "fastapi", "run", "/opt/app/python/main.py", "--host", "0.0.0.0"]
CMD ["--port", "8080"]
