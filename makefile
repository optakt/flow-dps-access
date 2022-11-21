# The tag of the current commit, otherwise empty
VERSION := $(shell git describe --tags --abbrev=2 --match "v*")

# The short Git commit hash
SHORT_COMMIT := $(shell git rev-parse --short HEAD)

# Image tag: if image tag is not set, set it with version (or short commit if empty)
ifeq (${IMAGE_TAG},)
IMAGE_TAG := ${VERSION}
endif

export DOCKER_BUILDKIT := 1

ALL_PACKAGES := ./...

# docker container registry
export CONTAINER_REGISTRY := gcr.io/flow-container-registry/flow-archive-access

# Dev Utilities
#############################################################################################################

.PHONY: unittest
unittest:
	go test -tags relic -v $(ALL_PACKAGES)

.PHONY: compile
compile:
	go build -tags relic $(ALL_PACKAGES)

.PHONY: integ-test
integ-test:
	go test -v -tags="relic integration" $(ALL_PACKAGES)

.PHONY: test
test: unittest integ-test

# Docker Utilities! Do not delete these targets
#############################################################################################################

.PHONY: docker-build-flow-archive-access
docker-build-flow-archive-access:
	 docker build . -t "$(CONTAINER_REGISTRY):$(IMAGE_TAG)"

.PHONY: docker-push-flow-archive-access
docker-push-flow-archive-access:
	docker push "$(CONTAINER_REGISTRY):$(IMAGE_TAG)"
