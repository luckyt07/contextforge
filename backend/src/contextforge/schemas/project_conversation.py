from datetime import datetime
from pydantic import BaseModel, ConfigDict


class ProjectConversationBase(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    conversation_id: str
    conversation_title: str


class ProjectConversationCreate(ProjectConversationBase):
    project_id: int


class ProjectConversationUpdate(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    conversation_title: str | None = None


class ProjectConversationOut(ProjectConversationBase):
    id: int
    project_id: int
    created_at: datetime
    updated_at: datetime
