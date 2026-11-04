from datetime import UTC, datetime
from typing import Annotated

from fastapi import Depends
from fastapi.security import (
    HTTPAuthorizationCredentials,
    HTTPBearer,
    OAuth2PasswordRequestForm,
)
from loguru import logger

from contextforge.api.dependencies.database import DBSessionDep
from contextforge.db.entities import User
from contextforge.core.exceptions import (
    AlreadyRegisteredException,
    EmailAlreadyExist,
    InvalidCredentials,
    UnauthorizedException,
)
from contextforge.schemas.token import TokenOut
from contextforge.schemas.user import UserCreate, UserInDB, UserInfo, UserOut
from contextforge.services.password_service import PasswordService
from contextforge.services.token_service import TokenService
from contextforge.services.user_service import UserService

security = HTTPBearer()

LoginFormDep = Annotated[OAuth2PasswordRequestForm, Depends()]
AuthHeaderDep = Annotated[HTTPAuthorizationCredentials, Depends(security)]


class AuthService:
    def __init__(self, session: DBSessionDep) -> None:
        self.password_service = PasswordService()
        self.token_service = TokenService(session)
        self.user_service = UserService(session)

    async def register_user(self, user: UserCreate) -> User:

        if await self.user_service.get(user.username):
            raise AlreadyRegisteredException
        if await self.user_service.get_user_by_email(user.email):
            raise EmailAlreadyExist

        try:
            hashed_password = await self.password_service.get_password_hash(
                user.password
            )
        finally:
            pass
        user_db = await self.user_service.create(
            UserInDB(
                username=user.username,
                password=hashed_password,
                role=user.role,
                email=user.email,
                firstname=user.firstname,
                lastname=user.lastname,
            )
        )
        return user_db

    async def authenticate_user(self, username, password) -> UserInfo:
        logger.debug(f"{username}|{password}")

        if not (user := await self.user_service.get(username)):
            logger.debug(f"username not found {username}")
            raise InvalidCredentials

        if not await self.password_service.verify_password(password, user.password):
            logger.debug(f"password mismatched {password}")
            raise UnauthorizedException
        user_dict = {
            "id": str(user.id),
            "username": user.username,
            "is_active": True,
        }

        token, refresh_token = await self.token_service.create_acess_token(user_dict)

        user_info = UserInfo(
            user=UserOut.model_validate(user),
            token=TokenOut(access_token=token, refresh_token=refresh_token),
        )

        return user_info

    async def get_current_user(self, credential: AuthHeaderDep) -> User:
        if credential.scheme != "Bearer":
            raise UnauthorizedException
        if not (token := credential.credentials):
            raise UnauthorizedException
        logger.debug("Decoding...")
        payload = await self.token_service.decode(token)
        logger.debug(f"Checking: {payload}")
        expire = payload['exp']

        expires_at = datetime.fromtimestamp(expire, UTC )
        now = datetime.now(UTC)
        logger.debug(f"{expires_at}-|-{now}")
        logger.debug(f"Boolean:::-> {now >= expires_at}")

        if now >= expires_at:

            raise UnauthorizedException

        if not await self.token_service.validate(payload["sub"]):
            raise UnauthorizedException

        if not (username := payload.get("username")):
            raise UnauthorizedException

        if not (user := await self.user_service.get(username)):
            raise UnauthorizedException

        return user

    async def update_token(self, refresh_token: str) -> TokenOut:
        session = await self.token_service.check_refresh_token(refresh_token)
        logger.debug(f"Update Token:-{session}")

        

        if not session:
            logger.debug("Session not found")
            raise UnauthorizedException
        
        if not session.is_active:
            logger.debug("Session not active")
            raise UnauthorizedException
        
        logger.debug(f"{session.expires_at.replace(tzinfo=UTC)}========{datetime.now(UTC)}========={type(session.expires_at)}")

        if session.expires_at.replace(tzinfo=UTC) <= datetime.now(UTC):
            logger.debug("Session expired")
            raise UnauthorizedException

        if not (user := await self.user_service.get_by_id(session.user_id)):
            logger.debug("User not found")
            raise UnauthorizedException

        user_dict = {
            "id": str(user.id),
            "username": user.username,
            "is_active": True,
        }

        token, new_refresh_token = await self.token_service.update_acess_token(
            session.id,
            user_dict,
        )
        return TokenOut(access_token=token, refresh_token=new_refresh_token)

    async def logout(self, credentials: AuthHeaderDep) -> None:
        payload = await self.token_service.decode(credentials.credentials)
        await self.token_service.deactivate(payload["sub"])
