#!/bin/bash -uex

# Docker build script for acme.sh containers.

BASE_IMAGE=$1

source "$BASE_IMAGE/env.sh"

DOCKER_OUTPUT="${DOCKER_OUTPUT:-type=image}"
SUPPORTED_ARCHITECTURES="${SUPPORTED_ARCHITECTURES}"
DOCKER_IMAGE="${DOCKER_IMAGE:-digimach/acme.sh}"
DOCKER_IMAGE_TAG="${DOCKER_IMAGE_TAG:-$BASE_IMAGE-dev}"
ACMESH_VERSION="${ACMESH_VERSION:-master}"

cd "$BASE_IMAGE" || exit

docker buildx build \
    --tag "$DOCKER_IMAGE:$DOCKER_IMAGE_TAG" \
    --output "$DOCKER_OUTPUT" \
    --build-arg acmesh_version="$ACMESH_VERSION" \
    --platform "$SUPPORTED_ARCHITECTURES" .
