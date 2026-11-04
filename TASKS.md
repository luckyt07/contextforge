# ContextForge Roadmap

## Phase 1: Prompt foundation

- [ ] Refine the system and summary prompts.
- [ ] Version prompts in MLflow and compare prompt changes against a fixed set of examples.

## Phase 2: Retrieval quality

- [ ] Combine semantic vector search with keyword search for hybrid retrieval.
- [ ] Add a reranker to reorder retrieved chunks before they reach the model.

## Phase 3: Answer traceability

- [ ] Show the documents, chunks, and page references used for each answer.
- [ ] Let users open the source context directly from an answer.

## Phase 4: YouTube knowledge assistant

- [ ] Accept a YouTube URL and ingest the available transcript.
- [ ] Generate a structured summary with topics and takeaways.
- [ ] Support chat over the video transcript, with timestamps when available.

## Phase 5: Evaluation and safety

- [ ] Build an evaluation dataset from representative documents and questions.
- [ ] Measure retrieval relevance and answer quality after prompt or RAG changes.
- [ ] Add guardrails and vulnerability checks for unsafe inputs, prompt injection, and data exposure.
