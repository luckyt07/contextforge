import os 
import aiofiles 
from aiofiles.os import makedirs
from fastapi import UploadFile

DEFAULT_CHUNK_SIZE = 1024 * 1024 * 50 # Chunk size: 50mb

async def savefile(file: UploadFile)->str:
    await makedirs("./uploads", exist_ok=True)
    file_path = os.path.join("./uploads", file.filename)

    async with aiofiles.open(file_path, "wb") as f:
        while chunk:= await file.read(DEFAULT_CHUNK_SIZE):
            await f.write(chunk)
    return file_path
