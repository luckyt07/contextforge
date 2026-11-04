from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from contextforge.repositories.repository import Repository

from contextforge.db.entities import Message
from contextforge.schemas.message import MessageCreate, MessageUpdate


class MessageRepository(Repository):
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def list(self, skip: int = 0, take: int = 100) -> list[Message]:
        async with self.session.begin():
            result = await self.session.execute(
                select(Message).offset(skip).limit(take)
            )
        return list(result.scalars().all())

    async def get(self, uid: int) -> Message | None:
        async with self.session.begin():
            result = await self.session.execute(
                select(Message).where(Message.id == uid)
            )
        return result.scalars().first()

    async def create(self, record: MessageCreate) -> Message:
        message = Message(conversation_id=record.conversation_id)
        async with self.session.begin():
            self.session.add(message)
        await self.session.refresh(message)
        return message

    async def update(self, uid: int, record: MessageUpdate) -> Message | None:
        message = await self.get(uid)
        if not message:
            return None

        async with self.session.begin():
            for key, value in record.model_dump(exclude_unset=True).items():
                setattr(message, key, value)
            self.session.add(message)
        await self.session.refresh(message)
        return message

    async def delete(self, uid: int) -> None:
        message = await self.get(uid)
        if message:
            async with self.session.begin():
                await self.session.delete(message)
