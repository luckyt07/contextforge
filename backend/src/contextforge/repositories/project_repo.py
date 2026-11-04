from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession
from contextlib import asynccontextmanager
from loguru import logger

from contextforge.repositories.repository import Repository

from contextforge.db.entities import Project, ProjectConversation
from contextforge.schemas.project import ProjectCreate, ProjectUpdate, ProjectUserUpdate


class ProjectRepository(Repository):
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    @asynccontextmanager
    async def _transaction(self):
        if self.session.in_transaction():
            # Reuse the existing transaction
            yield
        else:
            # Start and manage a new transaction
            async with self.session.begin():
                yield

    async def list(self, user_id: int, skip: int = 0, take: int = 100) -> list[Project]:
        logger.debug(f"Fetching projects for user_id: {user_id}")
        async with self._transaction():
            result = await self.session.execute(
                select(
                    Project,
                    func.count(ProjectConversation.id).label("conversation_count"),
                )
                .outerjoin(
                    ProjectConversation,
                    ProjectConversation.project_id == Project.id,
                )
                .where(Project.user_id == user_id)
                .group_by(Project.id)
                .offset(skip)
                .limit(take)
        )
        return [
        {
            **{
                column.name: getattr(project, column.name)
                for column in Project.__table__.columns
            },
            "conversation_count": conversation_count,
        }
        for project, conversation_count in result.all()
    ]
    async def get(self, uid: int) -> Project | None:
        async with self._transaction():
            result = await self.session.execute(
                select(Project).where(Project.id == uid)
            )
        return result.scalars().first()

    async def create(self, record: ProjectCreate) -> Project:
        project = Project(**record.model_dump())
        async with self._transaction():
            self.session.add(project)
        await self.session.refresh(project)
        return project

    async def update(self, uid: int, record: ProjectUpdate|ProjectUserUpdate) -> Project | None:
        project = await self.get(uid)
        if not project:
            return None

        async with self._transaction():
            for key, value in record.model_dump(exclude_unset=True).items():
                setattr(project, key, value)
            
            self.session.add(project)
            await self.session.commit()
        await self.session.refresh(project)
        return project

    async def delete(self, uid: int) -> None:
        project = await self.get(uid)
        if project:
            async with self._transaction():
                await self.session.delete(project)
