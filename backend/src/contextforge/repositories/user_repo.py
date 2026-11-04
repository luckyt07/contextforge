from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from contextforge.repositories.repository import Repository

from contextforge.db.entities import User
from contextforge.schemas.user import UserChangePassword, UserInDB, UserUpdate


class UserRepository(Repository):
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def list(self, skip: int = 0, take: int = 100) -> list[User]:
        async with self.session.begin():
            result = await self.session.execute(
                select(User).offset(skip).limit(take)
            )
        return list(result.scalars().all())

    async def get(self, uid: int) -> User | None:
        async with self.session.begin():
            result = await self.session.execute(
                select(User).where(User.id == uid)
            )
        return result.scalars().first()

    async def create(self, record: UserInDB) -> User:
        user = User(
            username=record.username,
            email=record.email,
            password=record.password,
        )
        async with self.session.begin():
            self.session.add(user)
        await self.session.refresh(user)
        return user

    async def update(self, uid: int, record: UserUpdate | UserChangePassword ) -> User | None:
        user = await self.get(uid)
        if not user:
            return None

        async with self.session.begin():
            for key, value in record.model_dump(exclude_unset=True).items():
                setattr(user, key, value)
            self.session.add(user)
        await self.session.refresh(user)
        return user

    async def delete(self, uid: int) -> None:
        user = await self.get(uid)
        if user:
            async with self.session.begin():
                await self.session.delete(user)
