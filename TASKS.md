# Upcoming Work

## Prompt quality

- [ ] Improve the system and summary prompts.
- [ ] Add prompt versioning and compare prompt changes through MLflow.

## Retrieval quality

- [ ] Add hybrid retrieval that combines dense vector search with keyword search.
- [ ] Add a reranker to improve the relevance order of retrieved documents.
- [ ] Measure retrieval quality before and after the hybrid retrieval and reranking changes.

## YouTube knowledge assistant

- [ ] Add YouTube video ingestion using a public video URL.
- [ ] Extract or import the video transcript, then generate a structured summary with key topics and takeaways.
- [ ] Index transcript chunks for retrieval so users can ask follow-up questions and chat with the video content.
- [ ] Return answers grounded in the video transcript, including relevant timestamps when available.

## Evaluation dataset

- [ ] Build a representative evaluation dataset from project documents and expected answers.
- [ ] Define retrieval and answer-quality metrics.
- [ ] Run the dataset automatically against prompt and retrieval changes.
