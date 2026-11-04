from typing import Annotated

from fastapi import Depends

from contextforge.api.dependencies.database import DBSessionDep
from contextforge.db.entities import User
from contextforge.services.auth_service import AuthHeaderDep, AuthService


def get_auth_service(session: DBSessionDep) -> AuthService:
    return AuthService(session)


AuthServiceDep = Annotated[AuthService, Depends(get_auth_service)]


async def get_current_user(
    auth_service: AuthServiceDep, credentials: AuthHeaderDep
) -> User:
    return await auth_service.get_current_user(credentials)


GetCurrentUserDep = Annotated[User, Depends(get_current_user), ]
