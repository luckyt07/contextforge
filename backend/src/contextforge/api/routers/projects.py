from typing import Annotated

from fastapi import (
    APIRouter,
    BackgroundTasks,
    Depends,
    File,
    Form,
    HTTPException,
    Request,
    UploadFile,
    status,
)
from fastapi.responses import StreamingResponse

from contextforge.api.dependencies.current_user import GetCurrentUserDep, get_current_user
from contextforge.api.dependencies.database import DBSessionDep
from contextforge.core.exceptions import ProjectForbidden, ProjectNotFound
from contextforge.rag.doc_ingestion import DocIngestion
from contextforge.repositories.project_repo import ProjectRepository
from contextforge.schemas.project import ProjectCreate, ProjectOut, ProjectUpdate, ProjectUserUpdate
from contextforge.services.files import savefile

router = APIRouter(
    prefix="/projects", tags=["Projects"], dependencies=[Depends(get_current_user)]
)



def project_form_data(
    project_name: str = Form(...),
    project_instruction: str = Form(...),
) -> ProjectCreate:
    return ProjectCreate(
        project_name=project_name,
        project_instruction=project_instruction,
        filename="",
        summary="",
    )


@router.get("/")
async def get_project_list_controller(
    current: GetCurrentUserDep,
    session: DBSessionDep,
):
    repo = ProjectRepository(session)
    projects = await repo.list(user_id=current.id)
    return projects


@router.post("/create")
async def create_project_controller(
    request: Request,
    file: Annotated[UploadFile, File(description="Upload Pdf documents")],
    currentUser: GetCurrentUserDep,
    session: DBSessionDep,
    background_task: BackgroundTasks,
    project: Annotated[ProjectCreate, Depends(project_form_data)],
) -> StreamingResponse:
    if file.content_type != "application/pdf":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Only pdf is allowed is allowed",
        )

    if project.user_id:
        if not project.user_id == currentUser.id:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST, detail="User id doesn't match"
            )
    else:
        project.user_id = currentUser.id

    repo = ProjectRepository(session)

    try:
        file_path = await savefile(file)
        project.filename = file_path
        project_out = await repo.create(project)
        out = ProjectOut.model_validate(project_out)
        doc_ingestion = DocIngestion(request.app.state.summary_system_message, session)
        doc_ingestion.setup_workflow()

        # output = ProjectOut.model_validate(project_out)
        # metadata = {"project-id": output.id, "user-id": output.user_id}
        # vector_store = VectorRepository(collection_name="v1-test")
        # background_task.add_task(vector_store.pre_process_pdf, file_path, metadata)

    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Something went wrong {e}",
        )

    return StreamingResponse(
        doc_ingestion.run_workflow(filepath=file_path, project=out),
        media_type="text/event-stream",
    )


@router.put("/{id}")
async def edit_project_controller(id: int, project_update: ProjectUserUpdate,currentUser:GetCurrentUserDep, session: DBSessionDep):
    repo = ProjectRepository(session)

    project = await repo.get(id)

    if not project:
        raise ProjectNotFound


    if project.user_id != currentUser.id:
        raise ProjectForbidden

    updated_project = await repo.update(id, project_update)

    return updated_project

@router.delete("/")
async def delete_project_controller(id: int, currentUser:GetCurrentUserDep, session: DBSessionDep):
    repo = ProjectRepository(session)
    
    project = await repo.get(id)
    
    if not project:
        raise ProjectNotFound
    
    if project.user_id != currentUser.id:
        raise ProjectForbidden

    await repo.delete(id)

    try:
        from contextforge.rag.cache_client import CacheClient
        cache_client = CacheClient()
        await cache_client.clear_cache(project_id=id, user_id=currentUser.id)
    except Exception as e:
        pass

    return {
        'status': status.HTTP_204_NO_CONTENT, 
        'detail': f'Project {project.project_name} is deleted successfully'
    }
