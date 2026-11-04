
from fastapi import APIRouter, Depends, HTTPException, status

from contextforge.api.dependencies.current_user import GetCurrentUserDep, get_current_user
from contextforge.api.dependencies.database import DBSessionDep
from contextforge.core.exceptions import ProjectForbidden, ProjectNotFound
from contextforge.integrations.groq import groq_client
from contextforge.repositories.project_conversation_repo import ProjectConversationRepository
from contextforge.repositories.project_repo import ProjectRepository

router = APIRouter(prefix="/project/conversations", tags=["Conversation"], dependencies=[Depends(get_current_user)])

@router.get('/')
async def get_project_conversation(
    project_id: int,
    session: DBSessionDep,
    user: GetCurrentUserDep,
   
):

    project_repo = ProjectRepository(session)
    project_conv_repo = ProjectConversationRepository(session)

    project = await project_repo.get(project_id)

    if project is None:
            raise ProjectNotFound
    
    if user.id != project.user_id:
        raise ProjectForbidden
    project_convs = await project_conv_repo.list(project_id=project_id)
    return project_convs



@router.get("/{conversation_id}")
async def get_conversation_history(conversation_id: str, currentUser: GetCurrentUserDep, session: DBSessionDep):
    repo_conv = ProjectConversationRepository(session)
    repo_projects = ProjectRepository(session)

    conversation = await repo_conv.get(conversation_id)

    if not conversation:
        raise HTTPException(detail="No Conversation found", status_code=status.HTTP_400_BAD_REQUEST)

    project = await repo_projects.get(conversation.project_id)

    if not project:
        raise ProjectNotFound

    if currentUser.id != project.user_id:
        raise ProjectForbidden

    return await groq_client.get_conversation_history(conversation_id, )


@router.delete("/")
async def delete_conversation_history(conversation_id: str, currentUser: GetCurrentUserDep, session: DBSessionDep):
    repo_conv = ProjectConversationRepository(session)
    repo_projects = ProjectRepository(session)

    conversation = await repo_conv.get(conversation_id)

    if not conversation:
        raise HTTPException(detail="No Conversation found", status_code=status.HTTP_400_BAD_REQUEST)

    project = await repo_projects.get(conversation.project_id)

    if not project:
        raise ProjectNotFound

    if currentUser.id != project.user_id:
        raise ProjectForbidden

    await groq_client.delete_conversation(conversation_id)
    
    await repo_conv.delete(conversation_id)

    return {
            'status': status.HTTP_204_NO_CONTENT, 
            'detail': f'Conversation \"{conversation.conversation_title}\" is deleted successfully'
        }
    
        
