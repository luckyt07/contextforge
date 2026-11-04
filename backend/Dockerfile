# 1. Base Image: Lightweight, modern Python 3.12
FROM python:3.12-slim

# 2. Environment settings for containerized Python
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PYTHONPATH=/app/src

# 3. Install minimal system packages for health checks
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 4. Set working directory
WORKDIR /app

# 5. Dependency Layer Caching
# Copy requirements first so Docker reuses cache if dependencies haven't changed
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 6. Copy Application Source Code
COPY . .

# 7. Create uploads directory and non-root user (Kubernetes Security Best Practice)
RUN mkdir -p /app/uploads && \
    useradd -m -u 1000 appuser && \
    chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# 8. Expose application port
EXPOSE 8000

# 9. Production Uvicorn Server Command
CMD ["uvicorn", "contextforge.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "2"]
