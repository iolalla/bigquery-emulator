VERSION ?= latest
REVISION := $(shell git rev-parse --short HEAD)

.PHONY: emulator/build docker/build docker/build/multiarch test/e2e debug help

# The SQL backend is pure Go, so the emulator builds without cgo and links a
# fully static binary on every platform.
emulator/build: ## Build the emulator binary
	CGO_ENABLED=0 go build -o bigquery-emulator-debug \
		-ldflags='-s -w -X main.version=${VERSION} -X main.revision=${REVISION}' \
		./cmd/bigquery-emulator

# The Dockerfile cross-compiles via the BuildKit platform args
# ($BUILDPLATFORM/$TARGETOS/$TARGETARCH), so it requires buildx.
docker/build: ## Build the local Docker image
	docker buildx build --load -t bigquery-emulator . \
		--build-arg VERSION=${VERSION} --build-arg REVISION=${REVISION}

# Build the multi-arch image exactly as CI does. Without --push buildx
# keeps the result in the build cache; add --push to publish a manifest.
docker/build/multiarch: ## Build the multi-architecture Docker image
	docker buildx build --platform linux/amd64,linux/arm64 -t bigquery-emulator . \
		--build-arg VERSION=${VERSION} --build-arg REVISION=${REVISION}

# Run the multi-language client conformance suite (Python/Ruby/PHP/Node.js/bq/Java).
# Requires a running Docker daemon; skips automatically when none is found.
test/e2e: ## Run the multi-language client conformance suite
	go test -count=1 -timeout 30m -v ./test/e2e/...

debug: ## Build the emulator with optimizations and inlining disabled
	CGO_ENABLED=0 go build -o bigquery-emulator-debug \
		-gcflags='all=-N -l' \
		-ldflags='-X main.version=${VERSION} -X main.revision=${REVISION}' \
		./cmd/bigquery-emulator

help: ## Show available targets
	@awk 'BEGIN {FS = ":.*## "; printf "Available targets:\n"} /^[[:alnum:]_\/.%-]+:.*## / {printf "  %-28s %s\n", $$1, $$2}' $(MAKEFILE_LIST)
