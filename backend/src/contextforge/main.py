from fastapi import FastAPI, status, UploadFile, File, BackgroundTasks, HTTPException
from fastapi.responses import StreamingResponse
from contextforge.integrations.groq import groq_client
from typing import Annotated
from contextforge.services.files import savefile
from contextforge.rag.vector_repository import VectorRepository
from contextlib import asynccontextmanager
import mlflow
import json
from pathlib import Path
from uuid import uuid4
from contextforge.db.database import engine
from starlette.middleware.sessions import SessionMiddleware
from contextforge.api.routers.auth import router as auth_router
from contextforge.api.routers.projects import router as project_router
from contextforge.api.routers.resource import router as generate_router
from langgraph.checkpoint.postgres.aio import AsyncPostgresSaver
import os
from contextforge.api.routers.project_conversations import router as conversation_router
from contextforge.api.routers.profile import router as profile_router
from loguru import logger
from contextforge.core.prompts import SYSTEM_PROMPT, SUMMARY_SYSTEM_PROMPT


@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("Backend startup: beginning application lifespan")

    mlflow_tracking_uri = os.getenv("MLFLOW_TRACKING_URI", "http://127.0.0.1:5000")
    logger.info("Backend startup: configuring MLflow tracking URI")
    mlflow.set_tracking_uri(mlflow_tracking_uri)

    logger.info("Backend startup: enabling MLflow LangChain autologging")
    mlflow.langchain.autolog()

    experiment_name = os.getenv("MLFLOW_EXPERIMENT_NAME", "02-localhost-app")
    logger.info("Backend startup: selecting MLflow experiment '{}'", experiment_name)
    mlflow.set_experiment(experiment_name)
    logger.success("Backend startup: MLflow is ready")

    prompt_alias = os.getenv("PROMPT_ALIAS", "production")
    LANGGRAPH_URI = os.environ["DB_URL"].strip("\"'").replace("+psycopg", "") 

    # --- System Prompt with MLflow Fallback ---
    logger.info("Backend startup: loading system prompt from MLflow")
    try:
        raw_system_prompt = mlflow.genai.load_prompt(f"prompts:/system_prompt@{prompt_alias}")
        system_prompt_str = raw_system_prompt.to_single_brace_format()
        logger.success("Backend startup: loaded 'system_prompt' from MLflow")
    except Exception:
        logger.opt(exception=True).warning(
            "Backend startup: could not load 'system_prompt' from MLflow; using local fallback"
        )
        system_prompt_str = SYSTEM_PROMPT

    # --- Summary System Prompt with MLflow Fallback ---
    logger.info("Backend startup: loading summary prompt from MLflow")
    try:
        raw_summary_prompt = mlflow.genai.load_prompt(f"prompts:/summary_system_prompt@{prompt_alias}")
        summary_prompt_str = raw_summary_prompt.to_single_brace_format()
        logger.success("Backend startup: loaded 'summary_system_prompt' from MLflow")
    except Exception:
        logger.opt(exception=True).warning(
            "Backend startup: could not load 'summary_system_prompt' from MLflow; using local fallback"
        )
        summary_prompt_str = SUMMARY_SYSTEM_PROMPT

    app.state.summary_system_message = summary_prompt_str

    logger.info("Backend startup: initializing the Groq client")
    groq_client.init(system_prompt_str)
    logger.success("Backend startup: Groq client is ready")

    logger.info("Backend startup: initializing LangGraph checkpoint storage")
    try:
        await groq_client.set_up_graph(LANGGRAPH_URI)
    except Exception:
        logger.exception("Backend startup: LangGraph checkpoint initialization failed")
        raise
    logger.success("Backend startup: LangGraph checkpoint storage is ready")
    logger.success("Backend startup: application startup complete")

    yield

    logger.info("Backend shutdown: closing clients and database connections")
    await groq_client.close()
    await engine.dispose()
    logger.success("Backend shutdown: complete")


app = FastAPI(lifespan=lifespan)

# app.add_middleware(SessionMiddleware, secret_key="my_secret_key")

app.include_router(auth_router, tags=["Auth"])
app.include_router(project_router, tags=["Projects"])
app.include_router(conversation_router, tags=["Conversation"])
app.include_router(generate_router, tags=["Generate"])
app.include_router(profile_router, tags=["Profile"])


# @app.get("/generate/text")
# def serve_text_to_text_controller(prompt: str) -> StreamingResponse:
#     return StreamingResponse(
#         content=groq_client.generate(prompt, 10, 1),
#         media_type="text/event-stream",
#     )


# @app.post("/create/project")
# async def file_upload_controller(
#     file: Annotated[UploadFile, File(description="Upload Pdf documents")],
#     project_name: str,
#     instruction: str,
#     background_task: BackgroundTasks,
# ):

#     project_id = uuid4().hex
#     metadata = {"project-id": project_id, "user-id": 0}
#     if file.content_type != "application/pdf":
#         raise HTTPException(
#             status_code=status.HTTP_400_BAD_REQUEST,
#             detail="Only pdf is allowed is allowed",
#         )
#     res = {
#         "id": project_id,
#         "project_name": project_name,
#         "desc": instruction,
#         "filename": file.filename,
#     }

#     try:
#         file_path = await savefile(file)
#         vector_store = VectorRepository(collection_name="v1-test")
#         background_task.add_task(vector_store.pre_process_pdf, file_path, metadata)
#         background_task.add_task(
#             append_data,
#             res,
#         )

#     except Exception as e:
#         raise HTTPException(
#             status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
#             detail=f"Something went wrong {e}",
#         )

#     return res


# @app.get("/projects")
# async def get_all_projects_controller():
#     if not JSON_FILE.exists():
#         return []

#     return json.loads(JSON_FILE.read_text())
