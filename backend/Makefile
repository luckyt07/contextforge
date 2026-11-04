SHELL := /bin/sh

COMPOSE := docker compose
NAMESPACE := ai-assistant
IMAGE ?= itzluckytomar/ai-assistant
# A distinct tag makes Kubernetes pull the image built for this update.
TAG ?= $(shell date +%Y%m%d%H%M%S)
IMAGE_REF := $(IMAGE):$(TAG)

K8S_MANIFESTS := \
	k8s/postgres/deployment.yaml \
	k8s/postgres/service.yml \
	k8s/redis/deployment.yaml \
	k8s/redis/service.yaml \
	k8s/qdrant/deployment.yaml \
	k8s/qdrant/service.yaml \
	k8s/mlflow/deployment.yaml \
	k8s/mlflow/service.yaml \
	k8s/backend/deployment.yaml \
	k8s/backend/service.yaml
K8S_FLAGS := $(foreach manifest,$(K8S_MANIFESTS),-f $(manifest))

.PHONY: api-run dev-up dev-down full-up full-down k8s-up k8s-down k8s-update

api-run:
	PYTHONPATH=src uvicorn contextforge.main:app --host 0.0.0.0 --port 8000 --reload

dev-up:
	$(COMPOSE) -f docker-compose-dev.yml up --build -d

dev-down:
	$(COMPOSE) -f docker-compose-dev.yml down

local-up:
	$(COMPOSE) -f docker-compose.yml up --build -d

local-down:
	$(COMPOSE) -f docker-compose.yml down

full-up:
	$(COMPOSE) -f docker-compose.full.yml up --build -d

full-down:
	$(COMPOSE) -f docker-compose.full.yml down
