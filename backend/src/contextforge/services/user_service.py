from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from contextforge.db.entities import User
from contextforge.schemas.user import UserInDB

import traceback


class UserService:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def get(self, username: str) -> User | None:
        async with self.session.begin():
            result = await self.session.execute(
                select(User).where(User.username == username)
            )
        return result.scalars().first()

    async def get_by_id(self, uid: int) -> User | None:
        async with self.session.begin():
            result = await self.session.execute(select(User).where(User.id == uid))
        return result.scalars().first()

    async def get_user_by_email(self, email: str) -> User | None:
        async with self.session.begin():
            result = await self.session.execute(select(User).where(User.email == email))
        return result.scalars().first()

    async def create(self, user: UserInDB) -> User:
        model = User(**user.model_dump())

        async with self.session.begin():
            self.session.add(model)

            await self.session.flush()

            await self.session.refresh(model)

            await self.session.commit()

        return model
