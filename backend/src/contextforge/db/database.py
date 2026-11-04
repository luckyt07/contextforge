from sqlalchemy.ext.asyncio import create_async_engine
import os
from dotenv import load_dotenv
from contextforge.db.entities import Base

load_dotenv()

db_url = os.environ["DB_URL"].strip("\"'")

engine = create_async_engine(db_url)


async def init_db()->None:
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
        await conn.run_sync(Base.metadata.create_all)

async def reset_db():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
