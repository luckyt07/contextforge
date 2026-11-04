import asyncio
from collections.abc import AsyncGenerator

from dotenv import load_dotenv
from langchain_core.documents import Document
from langchain_core.messages import AIMessage, HumanMessage
from langchain_core.output_parsers import (
    CommaSeparatedListOutputParser,
)
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langgraph.checkpoint.postgres.aio import AsyncPostgresSaver
from langgraph.config import get_stream_writer
from langgraph.graph import END, START, MessagesState, StateGraph
from psycopg import AsyncConnection
from psycopg.rows import dict_row
from qdrant_client import models

from contextforge.integrations.llm import CustomAiModel
from contextforge.rag.cache_client import CacheClient
from contextforge.rag.doc_retriever import DocRetriever
from contextforge.rag.vector_repository import VectorRepository

load_dotenv()


class State(MessagesState):
    project_id: int
    user_id: int
    context: list[Document]
    summary: str
    query: list[str]


class GroqClient:
    def __init__(self) -> None:

        self.reasoning_token = "<|REASONING|>"
        self.content_token = "<|CONTENT|>"
        self.end_token = "<|END|>"

    def init(self, system_prompt: str):
        self.workflow = StateGraph(State)

        self.vector_store = VectorRepository(collection_name="v1-test")
        
        # Initialize cache client and doc retriever
        cache_client = CacheClient()
        self.doc_retriever = DocRetriever(
            cache_client=cache_client,
            vector_store=self.vector_store
        )
        
        self.prompt = ChatPromptTemplate.from_messages(
            [
                ("system", system_prompt),
                MessagesPlaceholder(variable_name="history"),
                ("user", "context:{context}\n\nquestion: {prompt}"),
            ]
        )

        self.llm = CustomAiModel.get_groq_model()

        self.chain = self.prompt | self.llm

    async def set_up_graph(self, db_url):
        self.workflow.add_node("query_rewriting", self.query_rewriting)
        self.workflow.add_node("retriever", self.retrive_docs_node)
        self.workflow.add_node("llm_call", self.call_llm)

        self.workflow.add_edge(START, "query_rewriting")
        self.workflow.add_edge("query_rewriting", "retriever")
        self.workflow.add_edge("retriever", "llm_call")
        self.workflow.add_edge("llm_call", END)

        self.connection = await AsyncConnection.connect(
            db_url,
            autocommit=True,
            prepare_threshold=0,
            row_factory=dict_row,
        )

        self.checkpointer = AsyncPostgresSaver(self.connection)
        await self.checkpointer.setup()
        self.app = self.workflow.compile(checkpointer=self.checkpointer)

    async def close(self):
        if self.connection is not None:
            await self.connection.close()

    async def query_rewriting(self, state: State):
        output_parser = CommaSeparatedListOutputParser()
        query = state["messages"][-1].content
        prompt = ChatPromptTemplate(
            [
                (
                    "system",
                    (
                        "You are multi query generator assistant, you will be provided the user question along with the document summary"
                        "you have generate a query which can retrive the data from vector db effectively and resolve issues so generate 5 question max"
                        f"output format instruction: {output_parser.get_format_instructions()}"
                    ),
                ),
                ("user", "Summary: {sumarry}\n\nquery:{query}"),
            ]
        )
        model = CustomAiModel.get_groq_model()

        chain = prompt | model | output_parser
        response = await chain.ainvoke({"sumarry": state["summary"], "query": query})

        return {"query": response}

    async def retrive_docs_node(self, state: State):
        writer = get_stream_writer()
        writer(
            {
                "event": "status",
                "node": "retrieve",
                "message": "Searching documents",
            }
        )
        metadata_filter = models.Filter(
            must=[
                models.FieldCondition(
                    key="metadata.project-id",
                    match=models.MatchValue(value=state["project_id"]),
                ),
                models.FieldCondition(
                    key="metadata.user-id",
                    match=models.MatchValue(value=state["user_id"]),
                ),
            ]
        )
        search_kwargs = {
            "k": 4,
            "filter": metadata_filter,
        }

        # Get the LangChain retriever from vector repository
        retriever = self.vector_store.get_retriever(search_kwargs=search_kwargs)

        # Retrieve documents using the caching retriever
        original_prompt = state["messages"][-1].content if state.get("messages") else None
        context = await self.doc_retriever.retrieve(
            query="\n\n".join(state["query"]),
            project_id=state["project_id"],
            user_id=state["user_id"],
            retriever=retriever,
            cache_query=original_prompt,
        )

        writer(
            {
                "event": "status",
                "node": "retrieve",
                "message": "Document retrieval complete",
            }
        )
        return {"context": context}

    async def call_llm(self, state: State):
        writer = get_stream_writer()
        response = []
        async for event in self.chain.astream_events(
            {
                "history": state["messages"][:-1],
                "context": state["context"],
                "prompt": state["messages"][-1].content,
            },
            version="v2",
        ):
            if event["event"] == "on_chat_model_stream":
                chunk: AIMessage = event["data"]["chunk"]
                if "reasoning_content" in chunk.additional_kwargs:
                    reason_content = chunk.additional_kwargs["reasoning_content"]
                    writer(
                        {
                            "event": "reasoning",
                            "node": "llm",
                            "message": reason_content,
                        }
                    )
                elif chunk.content:
                    response += chunk.content
                    writer(
                        {
                            "event": "message",
                            "node": "llm",
                            "message": chunk.content,
                        }
                    )
        final_response = "".join(response)

        return {"messages": [AIMessage(content=final_response)]}

    async def generate(
        self,
        user_prompt: str,
        project_id: int,
        user_id: int,
        thread_id: str,
        summary: str,
    ) -> AsyncGenerator[str, None]:

        initial_state: State = {
            "messages": [HumanMessage(content=user_prompt)],
            "project_id": project_id,
            "user_id": user_id,
            "summary": summary,
            "context": [],
            "query": [],
        }
        config = {"configurable": {"thread_id": thread_id}}

        async for event in self.app.astream(
            initial_state,
            config=config,
            stream_mode=["custom"],
            version="v2",
        ):
            data = event["data"]

            if data["event"] == "reasoning":
                reason_content = data["message"]
                yield f"data: {self.reasoning_token}{reason_content}{self.reasoning_token}"

            if data["event"] == "message":
                content = data["message"]
                yield f"data: {self.content_token}{content}{self.content_token}"

            await asyncio.sleep(0.05)

        yield f"data: {self.end_token}"

    async def get_conversation_history(self, conversation_id: str)->list[dict]:
        config = {"configurable": {"thread_id": conversation_id}}
        snapshot = await self.app.aget_state(config)

        if not snapshot.values:
            return []

        messages = snapshot.values.get("messages", [])

        return [{"role": msg.type, "content": msg.content} for msg in messages]

    async def delete_conversation(self, conversation_id: str):
       await self.checkpointer.adelete_thread(conversation_id)

groq_client = GroqClient()
