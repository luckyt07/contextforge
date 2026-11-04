from langchain_core.documents import Document
from langchain_core.vectorstores import VectorStoreRetriever
from loguru import logger

from contextforge.rag.cache_client import CacheClient
from contextforge.rag.transform import embedding
from contextforge.rag.vector_repository import VectorRepository


class DocRetriever:
    """
    Semantic caching retriever that wraps retrieval operations.
    
    Accepts a LangChain retriever (passed from VectorRepository) or falls back to
    creating one from a VectorRepository.
    
    Workflow:
    1. Embeds the query
    2. Checks the semantic cache for a matching previous query
    3. If cache hit (similarity >= threshold): returns cached documents
    4. If cache miss: invokes the LangChain retriever, stores documents in cache, and returns them
    """
    def __init__(
        self, 
        cache_client: CacheClient | None = None, 
        vector_store: VectorRepository | None = None,
        default_threshold: float = 0.9,
    ) -> None:
        self.cache_client = cache_client or CacheClient()
        self.vector_store = vector_store
        self.embedding = embedding
        self.default_threshold = default_threshold

    async def retrieve(
        self, 
        query: str, 
        project_id: int, 
        user_id: int, 
        retriever: VectorStoreRetriever | None = None,
        search_kwargs: dict | None = None,
        threshold: float | None = None,
        cache_query: str | None = None,
    ) -> list[Document]:
        """
        Retrieve documents with semantic caching.
        
        Args:
            query: The query text to retrieve documents for (used by retriever).
            project_id: Project ID scoping the cache.
            user_id: User ID scoping the cache.
            retriever: LangChain VectorStoreRetriever instance passed from VectorRepository.
            search_kwargs: Search kwargs to build a retriever if retriever is None.
            threshold: Cosine similarity threshold for cache hit.
            cache_query: Optional string to embed for cache lookup/storage (e.g. original prompt).
        """
        sim_threshold = threshold if threshold is not None else self.default_threshold
        embed_text = cache_query if cache_query is not None else query

        # Resolve retriever instance
        if retriever is None:
            if self.vector_store is not None and search_kwargs is not None:
                retriever = self.vector_store.get_retriever(search_kwargs=search_kwargs)
            else:
                raise ValueError(
                    "Either a LangChain retriever or (vector_store and search_kwargs) must be provided."
                )

        try:
            # Step 1: Embed the query
            query_vector = await self.embedding.aembed_query(embed_text)
            
            # Step 2: Ensure cache collection exists
            try:
                await self.cache_client.initialize_collection(project_id, user_id)
            except Exception as e:
                logger.warning(
                    f"Failed to initialize cache collection: {e}. Proceeding with direct retrieval."
                )
            
            # Step 3: Search cache
            try:
                cached_documents = await self.cache_client.search(
                    project_id=project_id,
                    user_id=user_id,
                    query_vector=query_vector,
                    threshold=sim_threshold,
                )
                
                if cached_documents is not None:
                    logger.debug(
                        f"Semantic cache HIT for project {project_id}, user {user_id}"
                    )
                    return cached_documents
                    
            except Exception as e:
                logger.warning(f"Cache search failed: {e}. Falling back to retrieval.")
            
            # Step 4: Cache miss - invoke LangChain retriever
            logger.debug(
                f"Semantic cache MISS for project {project_id}, user {user_id} - invoking retriever"
            )
            documents = await retriever.ainvoke(query)
            
            # Step 5: Cache the results
            try:
                await self.cache_client.insert(
                    project_id=project_id,
                    user_id=user_id,
                    query_vector=query_vector,
                    documents=documents,
                )
            except Exception as e:
                logger.warning(f"Failed to cache results: {e}")
            
            return documents
            
        except Exception as e:
            logger.error(f"Error in document retrieval with cache: {e}")
            # Fallback to direct retriever invocation
            logger.info("Falling back to direct retriever invocation without cache")
            return await retriever.ainvoke(query)
