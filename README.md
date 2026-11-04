# ContextForge

ContextForge is a document-aware AI workspace with a Flutter client and a FastAPI backend. It supports project-based conversations, document ingestion, retrieval-augmented generation, authentication, MLflow tracking, Redis caching, PostgreSQL persistence, and Qdrant vector search.

## Repository structure

```text
app/        Flutter frontend
backend/    FastAPI backend, Docker, Kubernetes, and database migrations
```

## Prerequisites

- Flutter SDK
- Python 3.12
- Docker Desktop
- Kubernetes enabled in Docker Desktop for Kubernetes commands

## Backend setup

```bash
cd backend
python3.12 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
cp k8s/k8s.env.example k8s/k8s.env
```

Configure the values in `.env` and `k8s/k8s.env`. These files contain local credentials and must not be committed.

## Run FastAPI locally

```bash
cd backend
source .venv/bin/activate
make api-run
```

The API documentation is available at `http://localhost:8000/docs`.

## Run the backend with Docker Compose

```bash
cd backend
make dev-up
```

The development API is available at `http://localhost:8080/docs`.

Stop the development stack with:

```bash
make dev-down
```

## Frontend setup

```bash
cd app
flutter pub get
flutter run
```

## Security

Do not commit `.env`, `k8s/k8s.env`, databases, uploads, MLflow artifacts, credentials, or generated build files. Use the supplied example configuration files as templates.
