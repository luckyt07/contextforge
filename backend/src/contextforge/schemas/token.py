from datetime import datetime

from pydantic import BaseModel


class TokenBase(BaseModel):
    user_id: str
    expires_at: datetime
    is_active: bool = True
    ip_address: str | None = None


class TokenCreate(TokenBase):
    refresh_token_hash: str

class RefreshToken(BaseModel):
    refresh_token_hash: str
    expires_at: datetime

    

class TokenUpdate(BaseModel):
    is_active: bool = False
    expires_at: datetime

class TokenOut(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "Bearer"