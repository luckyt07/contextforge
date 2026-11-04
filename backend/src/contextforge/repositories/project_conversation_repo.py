from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from contextforge.repositories.repository import Repository

from contextforge.db.entities import ProjectConversation
from contextforge.schemas.project_conversation import (
    ProjectConversationCreate,
    ProjectConversationUpdate,
)


class ProjectConversationRepository(Repository):
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def list(self, project_id: int, skip: int = 0, take: int = 100, ) -> list[ProjectConversation]:
        async with self.session.begin():
            result = await self.session.execute(
                select(ProjectConversation).where(ProjectConversation.project_id == project_id).offset(skip).limit(take)
            )
        return list(result.scalars().all())

    async def get(self, uid: str) -> ProjectConversation | None:
        async with self.session.begin():
            result = await self.session.execute(
                select(ProjectConversation).where(ProjectConversation.conversation_id == uid)
            )
        return result.scalars().first()

    async def create(self, record: ProjectConversationCreate) -> ProjectConversation:
        conversation = ProjectConversation(**record.model_dump())
        async with self.session.begin():
            self.session.add(conversation)
        await self.session.refresh(conversation)
        return conversation

    async def update(
        self, uid: int, record: ProjectConversationUpdate
    ) -> ProjectConversation | None:
        conversation = await self.get(uid)
        if not conversation:
            return None

        async with self.session.begin():
            for key, value in record.model_dump(exclude_unset=True).items():
                setattr(conversation, key, value)
            self.session.add(conversation)
        await self.session.refresh(conversation)
        return conversation

    async def delete(self, uid: str) -> None:
        conversation = await self.get(uid)
        if conversation:
            async with self.session.begin():
                await self.session.delete(conversation)
