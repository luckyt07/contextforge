from pydantic import BaseModel, ConfigDict


class MessageBase(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    conversation_id: int
    content: str | None = None
    sender: str | None = None


class MessageCreate(MessageBase):
    pass


class MessageUpdate(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    content: str | None = None
    sender: str | None = None


class MessageOut(MessageBase):
    id: int
