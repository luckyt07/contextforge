import asyncio

from langchain_community.document_loaders import PyPDFLoader
from langchain_core.documents import Document
from langchain_text_splitters import RecursiveCharacterTextSplitter
from loguru import logger


class DocumentProcessing:

    async def process_doc(
        self, file_path: str, metadata: dict, password: str | None = None
    ) -> list[Document]:
        pdf_loader = PyPDFLoader(file_path, password=password)
        logger.debug("pdf loader initiated")
        splitter = RecursiveCharacterTextSplitter(chunk_size=800, chunk_overlap=100)

        docs = await pdf_loader.aload()

        logger.debug("Docs loaded")
        splitted_docs = await asyncio.to_thread(splitter.split_documents, docs)
        
        if len(metadata.keys()) >= 1:
            for doc in splitted_docs:
                doc.metadata.update(**metadata)

        return splitted_docs

    
