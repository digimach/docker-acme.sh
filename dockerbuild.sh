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
ACMESH_VERSION=master

if [[ "$GITHUB_REF" == refs/tags/* ]]; then
    ACMESH_VERSION="${GITHUB_REF#refs/tags/}"
    DOCKER_IMAGE_TAG="${BASE_IMAGE}-${ACMESH_VERSION}"
elif [[ "$GITHUB_REF" == refs/heads/* ]]; then
    ACMESH_VERSION="${GITHUB_REF#refs/heads/}"
    DOCKER_IMAGE_TAG="${BASE_IMAGE}-${ACMESH_VERSION}"
fi

if [[ "$ACMESH_VERSION" == master ]]; then
    DOCKER_IMAGE_TAG="${BASE_IMAGE}-latest"
    AUTO_UPGRADE=1
fi

cd "$BASE_IMAGE" || exit

docker buildx build \
    --tag "$DOCKER_IMAGE:$DOCKER_IMAGE_TAG" \
    --output "$DOCKER_OUTPUT" \
    --build-arg auto_upgrade="$AUTO_UPGRADE" \
    --build-arg acmesh_version="$ACMESH_VERSION" \
    --platform "$SUPPORTED_ARCHITECTURES" .
