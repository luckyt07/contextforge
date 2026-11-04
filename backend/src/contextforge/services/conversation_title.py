from langchain_core.prompts import ChatPromptTemplate
from contextforge.integrations.llm import CustomAiModel
from langchain_openai import ChatOpenAI
from langchain_core.output_parsers import StrOutputParser
from sqlalchemy.ext.asyncio import AsyncSession
from contextforge.schemas.project_conversation import ProjectConversationCreate
from contextforge.repositories.project_conversation_repo import ProjectConversationRepository
from loguru import logger


class GetConversationTitle:

    def __init__(self, system_prompt) -> None:
        self.system_prompt = system_prompt

        self.prompt = ChatPromptTemplate([
            ('system', self.system_prompt), 
            ('user', "Title Needed for this: {prompt}")
        ])

        self.model = CustomAiModel.get_groq_model()

        self.chain = self.prompt | self.model | StrOutputParser()


    async def get_conversation_title(self, user_prompt: str, session: AsyncSession, project_id: int, conv_id: str):
        response = await self.chain.ainvoke({'prompt': user_prompt})

        project_conv_repo = ProjectConversationRepository(session)
        project_conv_create = ProjectConversationCreate(project_id=project_id, conversation_title=response, conversation_id=conv_id)
        
        resp = await project_conv_repo.create(project_conv_create)
        logger.debug(f"Conversation created with id: {resp.id}")

        
