#!/bin/bash -uex

# Docker build script for acme.sh containers.

BASE_IMAGE=$1

source "$BASE_IMAGE/env.sh"

DOCKER_OUTPUT="${DOCKER_OUTPUT:-type=image,push=true}"
SUPPORTED_ARCHITECTURES="${SUPPORTED_ARCHITECTURES}"
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
    --output "$DOCKER_OUTPUT" \
    --build-arg AUTO_UPGRADE="$AUTO_UPGRADE" \
    --platform "$SUPPORTED_ARCHITECTURES" .
