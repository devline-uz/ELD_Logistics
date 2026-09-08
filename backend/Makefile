SHELL := /bin/bash
.DEFAULT_GOAL := help

MODULE      := github.com/devline/onebook-eld
VERSION     ?= $(shell git rev-parse --short HEAD 2>/dev/null || echo dev)
LDFLAGS     := -s -w -X main.version=$(VERSION)
BIN         := bin
COMPOSE     := docker compose -f deploy/docker-compose.yml
MIGRATIONS  := db/migrations

# Shared integration-test stack (make test-env-up). The variable names are
# deliberately NOT TEST_DATABASE_URL/TEST_REDIS_URL: the bare `export` below
# would otherwise leak them into every target and silently repoint `make
# test-integration` at the shared containers.
TEST_PG_NAME    := eld-test-pg
TEST_REDIS_NAME := eld-test-redis
TEST_PG_PORT    ?= 55432
TEST_REDIS_PORT ?= 56379
TEST_PG_IMAGE   ?= timescale/timescaledb-ha:pg16
TEST_REDIS_IMAGE?= redis:7-alpine
TEST_PG_DSN     ?= postgres://postgres:postgres@127.0.0.1:$(TEST_PG_PORT)/eld_test?sslmode=disable
TEST_REDIS_DSN  ?= redis://127.0.0.1:$(TEST_REDIS_PORT)/0

-include .env
export

.PHONY: help
help: ## Show this help
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}'

## ---------- run / build ----------

.PHONY: run
run: ## Run the API server locally
	go run ./cmd/api

.PHONY: run-worker
run-worker: ## Run the asynq worker locally
	go run ./cmd/worker

.PHONY: build
build: ## Build api, worker and migrate into bin/
	@mkdir -p $(BIN)
	go build -trimpath -ldflags "$(LDFLAGS)" -o $(BIN)/api     ./cmd/api
	go build -trimpath -ldflags "$(LDFLAGS)" -o $(BIN)/worker  ./cmd/worker
	go build -trimpath -ldflags "$(LDFLAGS)" -o $(BIN)/migrate ./cmd/migrate

.PHONY: tidy
tidy: ## go mod tidy
	go mod tidy

## ---------- quality ----------

.PHONY: test
test: ## Unit tests
	go test -race -count=1 ./...

.PHONY: test-integration
test-integration: ## Integration tests (testcontainers)
	go test -race -count=1 -tags=integration -timeout=15m ./...

## ---------- shared test environment ----------

.PHONY: test-env-up
test-env-up: ## Start the shared postgres+redis test stack and migrate it once
	@if [ -z "$$(docker ps -q -f name=^/$(TEST_PG_NAME)$$)" ]; then \
		docker rm -f $(TEST_PG_NAME) >/dev/null 2>&1 || true; \
		echo ">> starting $(TEST_PG_NAME) on :$(TEST_PG_PORT)"; \
		docker run -d --name $(TEST_PG_NAME) \
			-p $(TEST_PG_PORT):5432 \
			-e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=eld_test \
			$(TEST_PG_IMAGE) \
			postgres -c fsync=off -c full_page_writes=off \
				-c synchronous_commit=off -c max_connections=300 >/dev/null; \
	else echo ">> $(TEST_PG_NAME) already running"; fi
	@if [ -z "$$(docker ps -q -f name=^/$(TEST_REDIS_NAME)$$)" ]; then \
		docker rm -f $(TEST_REDIS_NAME) >/dev/null 2>&1 || true; \
		echo ">> starting $(TEST_REDIS_NAME) on :$(TEST_REDIS_PORT)"; \
		docker run -d --name $(TEST_REDIS_NAME) \
			-p $(TEST_REDIS_PORT):6379 \
			$(TEST_REDIS_IMAGE) redis-server --save '' --appendonly no >/dev/null; \
	else echo ">> $(TEST_REDIS_NAME) already running"; fi
	@echo ">> waiting for postgres"
	@for i in $$(seq 1 120); do \
		n=$$(docker logs $(TEST_PG_NAME) 2>&1 | grep -c "ready to accept connections" || true); \
		if [ "$$n" -ge 2 ] && docker exec $(TEST_PG_NAME) pg_isready -U postgres -d eld_test >/dev/null 2>&1; then break; fi; \
		sleep 1; \
		if [ $$i -eq 120 ]; then echo "postgres never became ready"; exit 1; fi; \
	done
	@echo ">> applying migrations"
	@for i in 1 2 3 4 5 6 7 8 9 10; do \
		go run ./cmd/migrate -dir $(MIGRATIONS) -dsn '$(TEST_PG_DSN)' up && break; \
		if [ $$i -eq 10 ]; then echo "migrations failed"; exit 1; fi; \
		sleep 2; \
	done
	@echo ""
	@echo "Shared test stack is up. Export these to reuse it:"
	@echo "  export TEST_DATABASE_URL='$(TEST_PG_DSN)'"
	@echo "  export TEST_REDIS_URL='$(TEST_REDIS_DSN)'"
	@echo "Or just run: make test-integration-fast"

.PHONY: test-env-down
test-env-down: ## Remove the shared postgres+redis test stack
	@docker rm -f $(TEST_PG_NAME) $(TEST_REDIS_NAME) >/dev/null 2>&1 || true
	@echo ">> removed $(TEST_PG_NAME) $(TEST_REDIS_NAME)"

.PHONY: test-integration-fast
test-integration-fast: ## Integration tests against the shared stack (make test-env-up first)
	TEST_DATABASE_URL='$(TEST_PG_DSN)' TEST_REDIS_URL='$(TEST_REDIS_DSN)' \
		go test -race -count=1 -tags=integration -timeout=15m ./...

.PHONY: test-matrix
test-matrix: ## Permission matrix (every swagger op x every default role) + HTTP contract tests (make test-env-up first)
	TEST_DATABASE_URL='$(TEST_PG_DSN)' TEST_REDIS_URL='$(TEST_REDIS_DSN)' \
		go test -race -count=1 -tags=integration -timeout=5m ./cmd/api/... ./internal/contract/...

.PHONY: cover
cover: ## Unit tests with a coverage report
	go test -race -count=1 -coverprofile=coverage.out ./...
	go tool cover -func=coverage.out | tail -1

.PHONY: vet
vet: ## go vet
	go vet ./...

.PHONY: lint
lint: ## golangci-lint
	golangci-lint run --timeout=5m

.PHONY: fmt
fmt: ## gofmt the tree
	gofmt -s -w .

.PHONY: check
check: vet lint test ## vet + lint + test

.PHONY: oasdiff
oasdiff: swag ## Fail when the current spec breaks the latest docs/history/ snapshot
	@latest="$$(ls docs/history/*.json 2>/dev/null | sort -V | tail -1)"; \
	if [ -z "$$latest" ]; then echo "no docs/history/*.json snapshot yet — skipping"; exit 0; fi; \
	echo ">> comparing $$latest -> docs/swagger.json"; \
	oasdiff breaking --fail-on ERR "$$latest" docs/swagger.json

.PHONY: ci
ci: vet lint swag-check oasdiff test test-integration ## Full local approximation of the CI pipeline (needs docker)

## ---------- codegen ----------

.PHONY: swag
swag: ## Regenerate docs/ from swag annotations
	swag init -g cmd/api/main.go -o docs --parseDependency --parseInternal

.PHONY: swag-check
swag-check: swag ## Fail when docs/ is stale
	git diff --exit-code docs/

.PHONY: sqlc
sqlc: ## Regenerate internal/db from db/queries
	sqlc generate

.PHONY: tools
tools: ## Install the codegen / lint toolchain
	go install github.com/swaggo/swag/cmd/swag@latest
	go install github.com/sqlc-dev/sqlc/cmd/sqlc@latest
	go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
	go install github.com/oasdiff/oasdiff@latest

## ---------- migrations ----------

.PHONY: migrate-up
migrate-up: ## Apply all pending migrations
	go run ./cmd/migrate -dir $(MIGRATIONS) up

.PHONY: migrate-down
migrate-down: ## Roll back the last migration (local only)
	go run ./cmd/migrate -dir $(MIGRATIONS) down

.PHONY: migrate-status
migrate-status: ## Show migration status
	go run ./cmd/migrate -dir $(MIGRATIONS) status

.PHONY: migrate-create
migrate-create: ## Create a migration: make migrate-create name=add_units
	@test -n "$(name)" || (echo "usage: make migrate-create name=<snake_case_name>" && exit 1)
	go run ./cmd/migrate -dir $(MIGRATIONS) create $(name) sql

## ---------- docker ----------

.PHONY: docker-up
docker-up: ## Start the local stack (postgres, redis, api, worker)
	$(COMPOSE) up -d --build

.PHONY: docker-down
docker-down: ## Stop the local stack
	$(COMPOSE) down

.PHONY: docker-clean
docker-clean: ## Stop the local stack and drop the volumes
	$(COMPOSE) down -v

.PHONY: docker-logs
docker-logs: ## Tail the api and worker logs
	$(COMPOSE) logs -f api worker
