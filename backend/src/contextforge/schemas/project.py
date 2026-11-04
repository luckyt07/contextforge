from datetime import datetime
from pydantic import BaseModel, ConfigDict


class ProjectBase(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    project_name: str
    project_instruction: str
    filename: str
    summary: str


class ProjectCreate(ProjectBase):
    user_id: int | None = None
    is_active: bool = False


class ProjectUpdate(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: int
    project_name: str | None = None
    project_instruction: str | None = None
    filename: str | None = None
    summary: str | None = None
    is_active: bool | None = None

class ProjectUserUpdate(BaseModel):
    project_name: str | None = None
    project_instruction: str | None = None



class ProjectOut(ProjectBase):
    id: int
    user_id: int
    created_at: datetime
    updated_at: datetime
