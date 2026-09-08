# syntax=docker/dockerfile:1.7
# Multi-stage build. Targets: `api`, `worker`, `migrate`.
#   docker build -f deploy/Dockerfile --target api    -t onebook-eld/api .
#   docker build -f deploy/Dockerfile --target worker -t onebook-eld/worker .

ARG GO_VERSION=1.26

# ---------- deps ----------
FROM golang:${GO_VERSION}-alpine AS deps
WORKDIR /src
RUN apk add --no-cache git ca-certificates tzdata
COPY go.mod go.sum ./
RUN --mount=type=cache,target=/go/pkg/mod go mod download

# ---------- builder ----------
FROM deps AS builder
ARG VERSION=dev
ARG TARGETOS=linux
ARG TARGETARCH=amd64
COPY . .
ENV CGO_ENABLED=0
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
    go build -trimpath -ldflags "-s -w -X main.version=${VERSION}" -o /out/api     ./cmd/api && \
    GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
    go build -trimpath -ldflags "-s -w -X main.version=${VERSION}" -o /out/worker  ./cmd/worker && \
    GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
    go build -trimpath -ldflags "-s -w -X main.version=${VERSION}" -o /out/migrate ./cmd/migrate

# ---------- api ----------
FROM gcr.io/distroless/static-debian12:nonroot AS api
WORKDIR /app
COPY --from=builder /out/api /app/api
COPY --from=builder /src/db/migrations /app/db/migrations
USER nonroot:nonroot
EXPOSE 8080
ENTRYPOINT ["/app/api"]

# ---------- worker ----------
FROM gcr.io/distroless/static-debian12:nonroot AS worker
WORKDIR /app
COPY --from=builder /out/worker /app/worker
USER nonroot:nonroot
ENTRYPOINT ["/app/worker"]

# ---------- migrate ----------
FROM gcr.io/distroless/static-debian12:nonroot AS migrate
WORKDIR /app
COPY --from=builder /out/migrate /app/migrate
COPY --from=builder /src/db/migrations /app/db/migrations
USER nonroot:nonroot
ENTRYPOINT ["/app/migrate"]
