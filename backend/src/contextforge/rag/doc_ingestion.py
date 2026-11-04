import json
from collections.abc import AsyncGenerator
from typing import Any, TypedDict

from langchain_core.documents import Document
from langgraph.config import get_stream_writer
from langgraph.graph import END, START, StateGraph
from loguru import logger

from contextforge.api.dependencies.database import DBSessionDep
from contextforge.rag.cache_client import CacheClient
from contextforge.rag.document_processing import DocumentProcessing
from contextforge.rag.summarization import Summarization
from contextforge.rag.vector_repository import VectorRepository
from contextforge.repositories.project_repo import ProjectRepository
from contextforge.schemas.project import ProjectOut, ProjectUpdate


class DocumentState(TypedDict):
    project: ProjectOut
    filepath: str
    metadata: dict
    password: str | None
    docs: list[Document]
    summary: str


class DocIngestion:
    def __init__(
        self,
        summary_system_message: str,
        session: DBSessionDep | None= None,
    ) -> None:
        self.vector_repo = VectorRepository()
        self.cache_client = CacheClient()
        self.doc_processor = DocumentProcessing()
        self.summarizer = Summarization(summary_system_message)
        if session:
            self.project_repo = ProjectRepository(session)
        else:
            self.project_repo = None

    def setup_workflow(self):

        self.workflow = StateGraph(DocumentState)

        self.workflow.add_node("doc_processor_node", self.doc_processor_node)
        self.workflow.add_node("vector_processor_node", self.vector_processor_node)
        self.workflow.add_node("summarizer_node", self.summarizer_node)
        self.workflow.add_node("save_db_node", self.save_db_node)

        self.workflow.add_edge(START, "doc_processor_node")
        self.workflow.add_edge("doc_processor_node", "vector_processor_node")
        self.workflow.add_edge("doc_processor_node", "summarizer_node")

        self.workflow.add_edge("summarizer_node", "save_db_node")
        self.workflow.add_edge("vector_processor_node", "save_db_node")
        self.workflow.add_edge("save_db_node", END)

        self.app = self.workflow.compile()

    async def run_workflow(
        self,
        filepath: str,
        project: ProjectOut,
        password: str | None = None,
    ) -> AsyncGenerator[str, None]:
        metadata = {"project-id": project.id, "user-id": project.user_id}
        state: DocumentState = {
            "filepath": filepath,
            "metadata": metadata,
            "password": password,
            "docs": [],
            "summary": "",
            "project": project,
        }
        async for event in self.app.astream(
            input=state,
            version="v2",
            stream_mode=["custom"],
        ):
            # LangGraph wraps custom writer payloads differently between
            # versions. Keep that implementation detail on the server and
            # expose one stable SSE contract to clients.
            payload = self._custom_payload(event)
            if payload is not None:
                yield f"data: {json.dumps(payload, default=str)}\n\n"

    @staticmethod
    def _custom_payload(event: Any) -> dict | None:
        if isinstance(event, dict):
            if event.get("type") == "custom":
                event = event.get("data")
            elif "data" in event and isinstance(event["data"], dict):
                event = event["data"]
        elif isinstance(event, (tuple, list)) and event:
            event = event[-1]

        return event if isinstance(event, dict) and "event" in event else None

    @staticmethod
    def _event(
        step: str,
        message: str,
        progress: int,
        *,
        status: str = "running",
        data: dict | None = None,
    ) -> dict:
        return {
            "event": "project_creation",
            "status": status,
            "step": step,
            "message": message,
            "progress": progress,
            "data": data,
        }

    async def doc_processor_node(self, state: DocumentState):
        writer = get_stream_writer()
        writer(self._event("document_processing", "Reading your document…", 5))
        docs = await self.doc_processor.process_doc(
            file_path=state["filepath"],
            metadata=state["metadata"],
            password=state["password"],
        )
        writer(self._event("document_processing", "Document processed", 25))
        return {"docs": docs}

    async def vector_processor_node(self, state: DocumentState):
        writer = get_stream_writer()
        writer(self._event("indexing", "Indexing document content…", 30))
        await self.vector_repo.add_documents(state["docs"])
        
        # Invalidate semantic cache for this project and user
        try:
            p_id = state["project"].id
            u_id = state["project"].user_id
            await self.cache_client.clear_cache(project_id=p_id, user_id=u_id)
            logger.debug(f"Invalidated semantic cache for project {p_id}, user {u_id}")
        except Exception as e:
            logger.warning(f"Failed to invalidate cache after adding documents: {e}")

        writer(self._event("indexing", "Document indexed", 45))
        return {}

    async def summarizer_node(self, state: DocumentState):
        writer = get_stream_writer()
        writer(self._event("summarizing", "Preparing summary…", 50))
        summary = await self.summarizer.summarize(state["docs"], writer)
        writer(self._event("summarizing", "Summary complete", 85))
        # print(f"Summary:---\n{summary}\n---")
        return {"summary": summary}

    async def save_db_node(self, state: DocumentState):
        if not self.project_repo:
            logger.info("Project repo not available - testing mode")
            return {}

        writer = get_stream_writer()
        logger.debug(f"Saving project with summary length: {len(state['summary'])} chars")
        writer(self._event("saving", "Saving project…", 90))
        p_id = state["project"].id
        project = ProjectUpdate(
            id=p_id,
            summary=state["summary"],
            is_active=True,
        )

        project_out = await self.project_repo.update(p_id, project)

        writer(
            self._event(
                "completed",
                "Project is ready",
                100,
                status="completed",
                data={"project": ProjectOut.model_validate(project_out).model_dump(mode="json")},
            )
        )
