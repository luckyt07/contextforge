import os
import uuid
from loguru import logger
from langchain_core.documents import Document
from qdrant_client import AsyncQdrantClient, models
from qdrant_client.http.models import Distance, PointStruct


class CacheClient:
    def __init__(
        self, 
        qdrant_url: str | None = None,
        vector_size: int = 1024
    ) -> None:
        url = qdrant_url or os.getenv("QDRANT_URL", "http://localhost:6333")
        self.client = AsyncQdrantClient(url=url)
        self.vector_size = vector_size
        self._known_collections: set[str] = set()

    def get_collection_name(self, project_id: int, user_id: int) -> str:
        """Standardized cache collection name for project + user scoping."""
        return f"cache_project_{project_id}_user_{user_id}"

    async def initialize_collection(self, project_id: int, user_id: int) -> None:
        """Create cache collection for a specific project and user if it doesn't exist."""
        collection_name = self.get_collection_name(project_id, user_id)
        
        if collection_name in self._known_collections:
            return

        try:
            if hasattr(self.client, "collection_exists"):
                collection_exists = await self.client.collection_exists(collection_name)
            else:
                collections = await self.client.get_collections()
                collection_exists = any(
                    col.name == collection_name for col in collections.collections
                )
            
            if not collection_exists:
                await self.client.create_collection(
                    collection_name=collection_name,
                    vectors_config=models.VectorParams(
                        size=self.vector_size, 
                        distance=Distance.COSINE
                    ),
                )
                logger.debug(f"Created cache collection: {collection_name}")
            
            self._known_collections.add(collection_name)
        except Exception as e:
            logger.error(f"Error initializing cache collection: {e}")
            raise

    async def search(
        self, 
        project_id: int, 
        user_id: int,
        query_vector: list[float], 
        threshold: float = 0.9
    ) -> list[Document] | None:
        """
        Search cache for similar query. Returns cached documents if similarity >= threshold.
        Returns None if no match found.
        """
        collection_name = self.get_collection_name(project_id, user_id)
        
        try:
            # Modern qdrant-client uses query_points(); older versions used search()
            if hasattr(self.client, "query_points"):
                response = await self.client.query_points(
                    collection_name=collection_name,
                    query=query_vector,
                    limit=1,
                    with_payload=True,
                )
                points = response.points
            elif hasattr(self.client, "search"):
                points = await self.client.search(
                    collection_name=collection_name,
                    query_vector=query_vector,
                    limit=1,
                    with_payload=True,
                )
            else:
                raise AttributeError("AsyncQdrantClient has neither 'query_points' nor 'search'")
            
            if points and points[0].score >= threshold:
                logger.debug(
                    f"Cache HIT for project {project_id}, user {user_id} (score: {points[0].score:.4f})"
                )
                # Deserialize documents from payload
                cached_docs_data = points[0].payload.get("documents", [])
                documents = [
                    Document(
                        page_content=doc["page_content"],
                        metadata=doc.get("metadata", {})
                    )
                    for doc in cached_docs_data
                ]
                return documents
            else:
                score_val = points[0].score if points else 0.0
                logger.debug(
                    f"Cache MISS for project {project_id}, user {user_id} (score: {score_val:.4f})"
                )
                return None
                
        except Exception as e:
            logger.error(f"Error searching cache: {e}")
            return None

    async def insert(
        self, 
        project_id: int, 
        user_id: int,
        query_vector: list[float], 
        documents: list[Document]
    ) -> None:
        """Insert query embedding and retrieved documents into cache."""
        collection_name = self.get_collection_name(project_id, user_id)
        
        try:
            # Serialize documents to dict format
            serialized_docs = [
                {
                    "page_content": doc.page_content,
                    "metadata": doc.metadata
                }
                for doc in documents
            ]
            
            point = PointStruct(
                id=str(uuid.uuid4()),
                vector=query_vector,
                payload={"documents": serialized_docs},
            )
            
            await self.client.upsert(
                collection_name=collection_name,
                points=[point]
            )
            
            logger.debug(f"Inserted query result into cache for project {project_id}, user {user_id}")
            
        except Exception as e:
            logger.error(f"Error inserting into cache: {e}")
            raise

    async def clear_cache(self, project_id: int, user_id: int) -> None:
        """Delete cache collection for a specific project and user (e.g. on new doc upload or deletion)."""
        collection_name = self.get_collection_name(project_id, user_id)
        try:
            await self.client.delete_collection(collection_name=collection_name)
            self._known_collections.discard(collection_name)
            logger.info(f"Cleared cache collection {collection_name}")
        except Exception as e:
            logger.warning(f"Error clearing cache collection {collection_name}: {e}")
