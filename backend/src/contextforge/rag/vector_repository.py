import os

from langchain_core.documents import Document
from langchain_core.vectorstores import VectorStoreRetriever
from langchain_qdrant import QdrantVectorStore
from loguru import logger

from contextforge.rag.transform import embedding


class VectorRepository:
    def __init__(self, collection_name: str="v1-test") -> None:

        self.qdrant_url = os.getenv("QDRANT_URL", "http://localhost:6333")

        self.vector_store = QdrantVectorStore.from_documents(
            documents=[],
            embedding=embedding,
            url=self.qdrant_url,
            collection_name=collection_name,
        )

    async def add_documents(self, docs: list[Document]):
    
        await self.vector_store.aadd_documents(docs)
        logger.debug("Document added")
        

    def get_retriever(self, search_kwargs: dict) -> VectorStoreRetriever:
        return self.vector_store.as_retriever(search_kwargs=search_kwargs)
