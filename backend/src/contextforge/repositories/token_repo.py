from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from contextforge.repositories.repository import Repository

from contextforge.db.entities import Token
from contextforge.schemas.token import TokenCreate, TokenUpdate, RefreshToken


class TokenRepository(Repository):
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def list(self, skip: int = 0, take: int = 100) -> list[Token]:
        async with self.session.begin():
            result = await self.session.execute(select(Token).offset(skip).limit(take))
        return list(result.scalars().all())

    async def get(self, uid: int) -> Token | None:
        async with self.session.begin():
            result = await self.session.execute(select(Token).where(Token.id == uid))
        return result.scalars().first()

    async def get_by_hash(self, hased_refresh_token: str) -> Token | None:
        async with self.session.begin():
            result = await self.session.execute(select(Token).where(Token.refresh_token_hash == hased_refresh_token))
        return result.scalars().first()

    async def create(self, record: TokenCreate) -> Token:
        token = Token(**record.model_dump())
        async with self.session.begin():
            self.session.add(token)
        await self.session.refresh(token)
        return token

    async def update(self, uid: int, record: TokenUpdate | RefreshToken) -> Token | None:
        token = await self.get(uid)
        if not token:
            return None

        async with self.session.begin():
            for key, value in record.model_dump(exclude_unset=True).items():
                setattr(token, key, value)
            self.session.add(token)
        await self.session.refresh(token)
        return token

    async def delete(self, uid: int) -> None:
        token = await self.get(uid)
        if token:
            async with self.session.begin():
                await self.session.delete(token)
