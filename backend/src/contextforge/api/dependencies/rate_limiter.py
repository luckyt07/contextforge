import os

import redis.asyncio as redis
from dotenv import load_dotenv
from fastapi import HTTPException, status
from loguru import logger
from redis.exceptions import RedisError

from contextforge.api.dependencies.current_user import GetCurrentUserDep

load_dotenv()

REDIS_URL = os.getenv("REDIS_URL", "redis://127.0.0.1:6379/0")

# Reusable Redis connection pool for high concurrency across container replicas
_redis_pool: redis.ConnectionPool | None = None


def get_redis_pool() -> redis.ConnectionPool:
    global _redis_pool
    if _redis_pool is None:
        _redis_pool = redis.ConnectionPool.from_url(
            REDIS_URL,
            max_connections=50,
            decode_responses=True,
        )
    return _redis_pool


def get_redis_client() -> redis.Redis:
    pool = get_redis_pool()
    return redis.Redis(connection_pool=pool)


class RateLimiter:
    """
    Distributed Redis-backed rate limiter dependency for FastAPI.
    
    Synchronizes request limits across all container replicas in Kubernetes.
    """
    def __init__(
        self,
        max_requests: int = int(os.getenv("RATE_LIMIT_MAX_REQUESTS", "10")),
        window_seconds: int = int(os.getenv("RATE_LIMIT_WINDOW_SECONDS", "60")),
        key_prefix: str = "rate_limit:generate",
    ) -> None:
        self.max_requests = max_requests
        self.window_seconds = window_seconds
        self.key_prefix = key_prefix

    async def __call__(
        self,
        user: GetCurrentUserDep,
    ) -> None:
        user_id = user.id
        cache_key = f"{self.key_prefix}:user:{user_id}"

        try:
            r = get_redis_client()
            async with r.pipeline(transaction=True) as pipe:
                pipe.incr(cache_key)
                pipe.expire(cache_key, self.window_seconds, nx=True)
                pipe.ttl(cache_key)
                current_count, _, ttl = await pipe.execute()

            if current_count > self.max_requests:
                retry_after = ttl if ttl > 0 else self.window_seconds
                logger.warning(
                    f"Rate limit exceeded for user {user_id}: {current_count}/{self.max_requests} "
                    f"requests in {self.window_seconds}s. Retry after {retry_after}s."
                )
                raise HTTPException(
                    status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                    detail=(
                        f"Rate limit exceeded. Maximum {self.max_requests} requests "
                        f"allowed per {self.window_seconds} seconds. Please try again in {retry_after} seconds."
                    ),
                    headers={"Retry-After": str(retry_after)},
                )

            logger.debug(
                f"Rate limit check passed for user {user_id}: {current_count}/{self.max_requests} (TTL: {ttl}s)"
            )

        except HTTPException:
            # Re-raise rate limit HTTP 429 exceptions
            raise
        except (RedisError, Exception) as e:
            # Fail open if Redis is temporarily unreachable so service remains available
            logger.error(f"Redis rate limiter encountered an error: {e}. Failing open.")
            return
