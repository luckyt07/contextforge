from fastapi import APIRouter, Body, Depends, HTTPException, status

from contextforge.api.dependencies.current_user import GetCurrentUserDep, get_current_user
from contextforge.api.dependencies.database import DBSessionDep
from contextforge.core.exceptions import ForbiddenRequest
from contextforge.repositories.user_repo import UserRepository
from contextforge.schemas.user import (
    UserChangePassword,
    UserChangePasswordRequest,
    UserOut,
    UserUpdate,
)
from contextforge.services.password_service import PasswordService
from contextforge.services.token_service import TokenService

router = APIRouter(
    prefix="/profile", tags=["Profile"], dependencies=[Depends(get_current_user)]
)


@router.get("/")
async def get_profile_controller(
    current_user: GetCurrentUserDep, session: DBSessionDep
):
    return UserOut.model_validate(current_user)


@router.patch("/")
async def edit_profile_controller(
    update_user: UserUpdate, current_user: GetCurrentUserDep, session: DBSessionDep
):
    # user_service = UserService(session)
    user_repo = UserRepository(session)

    # if (
    #     update_user.username
    #     and (user := await user_service.get(update_user.username))
    #     and user is not None
    # ):
    #     raise HTTPException(
    #         status_code=status.HTTP_400_BAD_REQUEST, detail="Username already in use"
    #     )

    # if (
    #     update_user.email
    #     and (user := await user_service.get_user_by_email(update_user.email))
    #     and user is not None
    # ):
    #     raise HTTPException(
    #         status_code=status.HTTP_400_BAD_REQUEST, detail="Email already in use"
    #     )

    user = await user_repo.update(current_user.id, update_user)

    return user


@router.post("/logout")
async def logout_user_Controller(
    current_user: GetCurrentUserDep,
    session: DBSessionDep,
    refresh_token: str = Body(...),
):
    token_service = TokenService(session=session)

    token = await token_service.get_by_hash(
        await token_service.hash_refresh_token(refresh_token)
    )

    if not token:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid Token given!"
        )

    if token.user_id != current_user.id:
        raise ForbiddenRequest

    await token_service.deactivate(token_id=token.id)

    return {"status": status.HTTP_200_OK, "message": "Logout successfully"}


@router.post("/change-password")
async def change_password_controller(
    request: UserChangePasswordRequest,
    current_user: GetCurrentUserDep,
    session: DBSessionDep,
):
    user_repo  = UserRepository(session)
    pwd_service = PasswordService()
    if request.new_password != request.new_confirm_password:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, 
            detail="Password not matched"
        )

    if not await pwd_service.verify_password(request.old_password, current_user.password):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, 
            detail="Invalid credentials"
        )

    update_password = UserChangePassword(password=request.new_password)
    await user_repo.update(uid=current_user.id, record=update_password)

    return {
        'status': status.HTTP_200_OK, 
        'message': "Password updated successfully"
    }
    

    

