from typing import Annotated

from fastapi import APIRouter, Body, Depends
from loguru import logger

from contextforge.api.dependencies.database import DBSessionDep
from contextforge.schemas.token import TokenOut
from contextforge.schemas.user import UserCreate, UserInfo, UserOut
from contextforge.services.auth_service import AuthService

router = APIRouter(prefix="/auth", tags=["Auth"])


def get_auth_service(session: DBSessionDep) -> AuthService:
    return AuthService(session)


AuthServiceDep = Annotated[AuthService, Depends(get_auth_service)]


@router.post("/register")
async def register_user_controller(
    auth_service: AuthServiceDep, user: UserCreate
) -> UserOut:
    new_user = await auth_service.register_user(user)
    return UserOut.model_validate(new_user)


@router.post("/login")
async def login_for_access_token_controller(
    auth_service: AuthServiceDep, username: str = Body(...), password: str = Body(...)
) -> UserInfo:
    logger.debug("Authentication Started")

    user_info = await auth_service.authenticate_user(username, password)
    return user_info
    #  = await auth_service.authenticate_user(login_form)
    # return TokenOut(access_token=access_token)

@router.post("/refresh")
async def refresh_token_controller(
    auth_service: AuthServiceDep, 
    refresh_token: str = Body(...)
) -> TokenOut:
    logger.debug(f"Refresh Token is started : {refresh_token}")

    token = await auth_service.update_token(refresh_token)
    return token

