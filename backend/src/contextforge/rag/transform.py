from contextforge.integrations.llm import CustomAiModel
import os
from dotenv import load_dotenv


load_dotenv()

model_name = "sentence-transformers/all-mpnet-base-v2"
model_kwargs = {"device": "cpu"}
encode_kwargs = {"normalize_embeddings": False}

# embedding = ...

embedding = CustomAiModel.get_openai_embedding_model()
