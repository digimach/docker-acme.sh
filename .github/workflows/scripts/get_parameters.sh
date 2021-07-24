#!/bin/bash -eu
# get_parameters.sh determines what acme.sh version to build and the docker image tags.
#
# This script sets two variables, 'acmesh_version' and `tag` used by downstream jobs.

echo "** Will determine acme.sh version and Docker tags"

env
if [[ "$GITHUB_REF" == refs/heads/main ]]; then
    # acme.sh uses master branch names, but we use main. While getting the artifacts
    # from acme.sh we use master.
    ACMESH_VERSION="master"
    DOCKER_IMAGE_TAG="${BASE_IMAGE}-${ACMESH_VERSION}-${DATE_STAMP}-$(echo "${PLATFORM}" | tr '/' '-')"
elif [[ "$GITHUB_REF" == refs/tags/* ]]; then
    # acme.sh doesn't tag with a prefix v, but this repo does. So we drop the v when
    # getting the artifacts from acme.sh and also tag without the v in docker images
    ACMESH_VERSION="${GITHUB_REF#refs/tags/v}"
    DOCKER_IMAGE_TAG="${BASE_IMAGE}-${ACMESH_VERSION}-${DATE_STAMP}-$(echo "${PLATFORM}" | tr '/' '-')"
elif [[ "$GITHUB_REF" == refs/heads/* ]]; then
    ACMESH_VERSION="${GITHUB_REF#refs/heads/}"
    DOCKER_IMAGE_TAG="${BASE_IMAGE}-${ACMESH_VERSION}-${DATE_STAMP}-$(echo "${PLATFORM}" | tr '/' '-')"
elif [[ "$GITHUB_EVENT_NAME" == "pull_request" ]]; then
    PULL_REQUEST_NUMBER=$(echo "$GITHUB_REF" | cut -f3 -d"/")
    ACMESH_VERSION="${GITHUB_BASE_REF#refs/heads/}"
    DOCKER_IMAGE_TAG="${BASE_IMAGE}-${ACMESH_VERSION}-pr-${PULL_REQUEST_NUMBER}-${DATE_STAMP}-$(echo "${PLATFORM}" | tr '/' '-')"
fi

echo ::set-output name=tag::"$DOCKER_IMAGE_TAG"
echo ::set-output name=acmesh_version::"$ACMESH_VERSION"
