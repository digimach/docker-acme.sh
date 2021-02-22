#!/bin/bash -uex

# Docker build script for acme.sh containers.

BASE_IMAGE=$1
PLATFORMS="${2:-linux/arm64/v8,linux/amd64,linux/arm/v6,linux/arm/v7,linux/386,linux/ppc64le,linux/s390x}"
OUTPUT="${3:-type=image,push=true}"
DOCKER_IMAGE="digimach/acme.sh"
DOCKER_IMAGE_TAG="${BASE_IMAGE}-dev"
GITHUB_REF=""
AUTO_UPGRADE=0

if [[ "$GITHUB_REF" == refs/tags/* ]]; then
    DOCKER_IMAGE_TAG="${BASE_IMAGE}-${GITHUB_REF#refs/tags/}"
elif [[ "$GITHUB_REF" == refs/heads/* ]]; then
    DOCKER_IMAGE_TAG="${BASE_IMAGE}-${GITHUB_REF#refs/heads/}"
fi

if [[ "$DOCKER_IMAGE_TAG" == master ]]; then
    DOCKER_IMAGE_TAG="${BASE_IMAGE}-latest"
    AUTO_UPGRADE=1
fi

cd "$BASE_IMAGE" || exit

docker buildx build \
    --tag "$DOCKER_IMAGE:$DOCKER_IMAGE_TAG" \
    --output "$OUTPUT" \
    --build-arg AUTO_UPGRADE="$AUTO_UPGRADE" \
    --platform "$PLATFORMS" .
