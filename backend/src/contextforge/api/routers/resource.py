from typing import Annotated
from uuid import uuid4
import logging

from fastapi import (
    APIRouter,
    BackgroundTasks,
    Depends,
    File,
    Form,
    HTTPException,
    UploadFile,
    status,
)
from fastapi.responses import StreamingResponse

from contextforge.api.dependencies.database import DBSessionDep
from contextforge.db.entities import User
from contextforge.integrations.groq import groq_client
from contextforge.rag.vector_repository import VectorRepository
from contextforge.repositories.project_repo import ProjectRepository
from contextforge.repositories.project_conversation_repo import ProjectConversationRepository
from contextforge.services.auth_service import AuthHeaderDep, AuthService
from contextforge.schemas.project_conversation import ProjectConversationCreate
from contextforge.services.files import savefile
from contextforge.services.conversation_title import GetConversationTitle
from contextforge.api.dependencies.rate_limiter import RateLimiter

logger = logging.getLogger(__name__)


def get_auth_service(session: DBSessionDep) -> AuthService:
    return AuthService(session)


AuthServiceDep = Annotated[AuthService, Depends(get_auth_service)]


async def get_current_user(
    auth_service: AuthServiceDep, credentials: AuthHeaderDep
) -> User:
    logger.debug("Validating current user credentials")
    return await auth_service.get_current_user(credentials)


GetCurrentUserDep = Annotated[User, Depends(get_current_user)]


router = APIRouter(
    prefix="/generate", tags=["Generate"], dependencies=[Depends(get_current_user)]
)


@router.get(
    "/text", 
    dependencies=[Depends(RateLimiter(max_requests=8, window_seconds=60 * 10))]
)
async def serve_text_to_text_controller(
    prompt: str,
    project_id: int,
    user: GetCurrentUserDep,
    dbSession: DBSessionDep,
    bg_tasks: BackgroundTasks,
    conversation_id: str | None = None,

) -> StreamingResponse:
    project_repo = ProjectRepository(dbSession)
    project_conv_repo = ProjectConversationRepository(dbSession)

    project = await project_repo.get(project_id)

    if project is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Given project is not found {project_id}",
        )

    if user.id != project.user_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="You cannot access this project",
        )

    if conversation_id == None:
        conversation_id = uuid4().hex
        conversation_id = f"{user.id}-{project_id}-{conversation_id}"
        conversation_title = GetConversationTitle("Given user prompt generate the simple title with no abbreviation")
        bg_tasks.add_task(conversation_title.get_conversation_title, prompt, dbSession, project.id, conversation_id)

    summary = project.summary


    return StreamingResponse(
        content=groq_client.generate(prompt, project_id=project_id, user_id=user.id, thread_id=conversation_id, summary=summary),
        media_type="text/event-stream",
    )
