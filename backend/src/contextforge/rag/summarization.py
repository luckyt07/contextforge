import itertools
import math

from dotenv import load_dotenv
from langchain_core.documents import Document
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnableLambda, RunnableParallel

from contextforge.integrations.llm import CustomAiModel

load_dotenv()
from loguru import logger


class Summarization:
    def __init__(self, system_prompt: str) -> None:
        self.prompt = ChatPromptTemplate.from_messages(
            [("system", system_prompt), ("human", "Rank: {rank} Summarize: {content}")]
        )

        self.llm = CustomAiModel.get_open_ai_model()
        self.chain = self.prompt | self.llm | StrOutputParser()

    async def summarize(self, docs: list[Document], writer=None) -> str:
        logger.debug("Summarization started")

        contents = [doc.page_content for doc in docs]
        if not contents:
            return ""

        size = 5
        completed = 0

        # Calculate progress units: parallel executions + final call.
        total = 1
        if len(contents) > size:
            count = math.ceil(len(contents) / size)
            total += math.ceil(count / size)

            while count > 1:
                count = math.ceil(count / size)
                total += math.ceil(count / size)

        def update(rank):
            nonlocal completed
            completed += 1

            if writer is not None:
                writer({
                    "event": "project_creation",
                    "status": "running",
                    "step": "summarizing",
                    "message": "Summarizing document…",
                    "progress": 50 + round(completed / total * 35),
                    "data": {
                        "stage": rank,
                        "completed": completed,
                        "total": total,
                    },
                })

        async def run_parallel(items, rank):
            results = []

            for batch in itertools.batched(items, size):
                parallel_dict = {
                    f"run_{i}": (
                        RunnableLambda(
                            lambda _, item=item: {
                                "rank": rank,
                                "content": "\n\n".join(item),
                            }
                        )
                        | self.chain
                    )
                    for i, item in enumerate(batch)
                }

                results.extend(
                    (await RunnableParallel(parallel_dict).ainvoke({})).values()
                )

                # One update after the entire parallel execution completes.
                update(rank)

            return results

        rank = "initial"

        if len(contents) > size:
            summaries = await run_parallel(
                list(itertools.batched(contents, size)), rank
            )
        else:
            logger.debug("Skipping initial summarization")
            summaries = contents

        logger.debug("Initial stage completed")

        rank = "intermediate"

        while len(summaries) > 1 and len(contents) > size:
            logger.debug("Intermediate stage in progress")

            summaries = await run_parallel(
                list(itertools.batched(summaries, size)), rank
            )

        logger.debug("Intermediate stage completed")

        final_summary = await self.chain.ainvoke({
            "rank": "final",
            "content": "\n\n".join(summaries),
        })

        update("final")
        logger.debug("Final stage completed")

        return final_summary
