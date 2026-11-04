import os
from langchain_openai import ChatOpenAI, OpenAIEmbeddings
from langchain_groq import ChatGroq
from dotenv import load_dotenv

load_dotenv()


class CustomAiModel:
    @staticmethod
    def get_openai_embedding_model(
        model: str = "BAAI/bge-m3",
        base_url: str = os.getenv("EMBEDDING_BASE_URL", "http://127.0.0.1:8001/v1"),
        api_key: str = os.environ["VLLM_API_KEY"],
    ) -> OpenAIEmbeddings:
        return OpenAIEmbeddings(
            model=model,
            base_url=base_url,
            api_key=api_key,
        )

    @staticmethod
    def get_open_ai_model(
        # mlx-community/Qwen2.5-3B-Instruct-4bit
        # mlx-community/Qwen2.5-7B-Instruct-4bit
        model: str = "mlx-community/Qwen2.5-7B-Instruct-4bit",
        temperature: int = 1,
        base_url: str = os.getenv("LLM_BASE_URL", "http://127.0.0.1:8002/v1"),
        api_key=os.environ["VLLM_API_KEY"],
    ) -> ChatOpenAI:
        return ChatOpenAI(
            model=model,
            temperature=temperature,
            base_url=base_url,
            api_key=api_key,
        )

    @staticmethod
    def get_groq_model(model="openai/gpt-oss-120b") -> ChatGroq:
        return ChatGroq(model=model)
