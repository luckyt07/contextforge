import re
from datetime import datetime
from typing import Annotated

from pydantic import (
    AfterValidator,
    AliasChoices,
    BaseModel,
    ConfigDict,
    Field,
    validate_call,
)

from contextforge.schemas.token import TokenBase, TokenOut


@validate_call
def validate_username(username: str) -> str:
    if not username.isalnum():
        raise ValueError("Username must be alphanumeric")
    return username


@validate_call
def validate_password(password: str) -> str:
    validations = [
        (
            lambda v: any(char.isdigit() for char in v),
            "Password must contains atleast one digit",
        ),
        (
            lambda v: any(char.islower() for char in v),
            "Password must contain atleast one lowercase letter",
        ),
        (
            lambda v: any(char.isupper() for char in v),
            "Password must contain atleast one uppercase letter",
        ),
    ]
    for validation, errmsg in validations:
        if not validation(password):
            raise ValueError(errmsg)

    return password


@validate_call
def validate_email(email: str) -> str:
    pattern = r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$"
    if not re.fullmatch(pattern, email):
        raise ValueError("Please provide valid email")
    return email


ValidUserName = Annotated[
    str, Field(min_length=3, max_length=20), AfterValidator(validate_username)
]

ValidPassword = Annotated[
    str,
    Field(min_length=8, max_length=64),
    AfterValidator(validate_password),
]

ValidEmail = Annotated[
    str,
    AfterValidator(validate_email),
]


class UserBase(BaseModel):
    model_config = ConfigDict(from_attributes=True, populate_by_name=True)

    username: ValidUserName
    email: ValidEmail = Field(
        validation_alias=AliasChoices("email", "useremail"),
        serialization_alias="email",
    )
    firstname: str = ""
    lastname: str = ""
    is_active: bool = True
    role: str = "USER"

    @property
    def useremail(self) -> str:
        return self.email


class UserCreate(UserBase):
    password: ValidPassword


class UserChangePasswordRequest(BaseModel):
    old_password: ValidPassword
    new_password: ValidPassword
    new_confirm_password: ValidPassword


class UserUpdate(BaseModel):
    # username: ValidUserName | None = None
    # email: ValidEmail | None = Field(
    #     default=None,
    #     validation_alias=AliasChoices("email", "useremail"),
    #     serialization_alias="email",
    # )
    firstname: str | None= None
    lastname: str | None= None

class UserChangePassword(BaseModel):
    password: str



class UserInDB(UserBase):
    password: str


class UserOut(UserBase):
    id: int
    created_at: datetime
    updated_at: datetime


class UserInfo(BaseModel):
    user: UserOut
    token: TokenOut
