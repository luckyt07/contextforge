from datetime import UTC, datetime, timedelta

from jose import jwt
from pydantic import UUID4
import asyncio
from contextforge.core.exceptions import UnauthorizedException
from contextforge.repositories.token_repo import TokenRepository
from contextforge.schemas.token import TokenCreate, TokenUpdate, RefreshToken
import traceback
import secrets
import hashlib
from contextforge.db.entities import Token
from loguru import logger


class TokenService(TokenRepository):
    secret_key = "anything_bizark"
    algorithm = "HS256"
    expires_in_minutes = 300
    expires_in_days = 30

    async def generate_refresh_token(self) -> str:
        return await asyncio.to_thread(secrets.token_urlsafe, 64)

    async def hash_refresh_token(self, token: str) -> str:
        return (
            await asyncio.to_thread(hashlib.sha256, token.encode("utf-8"))
        ).hexdigest()

    async def create_acess_token(
        self, data: dict, expires_delta: timedelta | None = None
    ) -> (str, str):
        try:
            to_encode = data.copy()

            refresh_token = await self.generate_refresh_token()

            hashed_refresh_token = await self.hash_refresh_token(refresh_token)

            if expires_delta:
                expire = datetime.now(UTC) + expires_delta
            else:
                expire = datetime.now(UTC) + timedelta(minutes=self.expires_in_minutes)

            refresh_expire = datetime.now(UTC) + timedelta(days=self.expires_in_days)

            token = await self.create(
                TokenCreate(
                    expires_at=refresh_expire,
                    user_id=data["id"],
                    refresh_token_hash=hashed_refresh_token,
                )
            )

            token_id = token.id

            to_encode.update({"exp": expire, "iss": "test_service", "sub": token_id})

            encode_jwt = jwt.encode(
                to_encode, self.secret_key, algorithm=self.algorithm
            )

            return encode_jwt, refresh_token
        except Exception as e:
            logger.error(f"Token creation failed: {e}", exc_info=True)

    async def update_acess_token(
        self, session_id: int, data: dict, expires_delta: timedelta | None = None
    ) -> (str, str):
        try:
            to_encode = data.copy()

            refresh_token = await self.generate_refresh_token()

            hashed_refresh_token = await self.hash_refresh_token(refresh_token)
            if expires_delta:
                expire = datetime.now(UTC) + expires_delta
            else:
                expire = datetime.now(UTC) + timedelta(minutes=self.expires_in_minutes)

            refresh_expire = datetime.now(UTC) + timedelta(days=self.expires_in_days)
            token = await self.update(
                session_id,
                RefreshToken(
                    expires_at=refresh_expire,
                    refresh_token_hash=hashed_refresh_token,
                ),
            )

            if not token:
                raise ValueError("Token is not found")

            token_id = token.id

            to_encode.update({"exp": expire, "iss": "test_service", "sub": token_id})

            encode_jwt = jwt.encode(
                to_encode, self.secret_key, algorithm=self.algorithm
            )

            return encode_jwt, refresh_token
        except Exception as e:
            logger.error(f"Token update failed: {e}", exc_info=True)

    async def check_refresh_token(self, refresh_token) -> Token | None:
        hashed_refresh_token = await self.hash_refresh_token(refresh_token)
        return await self.get_by_hash(hashed_refresh_token)

    async def deactivate(self, token_id: int) -> None:
        await self.update(
            uid=token_id,
            record=TokenUpdate(is_active=False, expires_at=datetime.now(UTC)),
        )

    async def decode(self, encoded_token: str) -> dict:
        try:
            logger.debug("Decoding JWT token")
            return await asyncio.to_thread(
                jwt.decode,
                encoded_token,
                self.secret_key,
                algorithms=self.algorithm,
                options={"verify_sub": False},
            )

        except Exception as e:
            logger.warning(f"JWT decode failed: {e}")
            raise UnauthorizedException

    async def validate(self, token_id: int) -> bool:
        return (token := await self.get(token_id)) is not None and token.is_active
