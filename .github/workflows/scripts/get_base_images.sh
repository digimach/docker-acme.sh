#!/bin/bash -eu
# get_base_images determines what base OS are buildable and which of those should be
# built.
# This script sets two variables, 'base_images_to_build' and `buildable_base_images`
# used by downstream jobs.

BUILDABLE_BASE_IMAGES=$(find . -mindepth 1 -maxdepth 1 -type d -not -name ".*" -printf '%f\n' | paste -d, -s -)
echo "::set-output name=buildable_base_images::$BUILDABLE_BASE_IMAGES"

TMP_CHANGES_FILE="$(mktemp)"
BASE_IMAGES_TO_BUILD=""

if [[ "${WORKFLOW}" == "pull_request" ]]; then
    # If this is a pull request, we build only what is needed. This is done by diffing
    # what has changed and based on the root folder the relevant base OS will be
    # built.

    TMP_CHANGES_FILE="$(mktemp)"

    # Push event - retrieve list of changed files
    git diff --name-only "c9bf53f9d4ca6aaa4c1cbd92743d99ed069c3194..$EVENT_AFTER" >"${TMP_CHANGES_FILE}"

    # TODO: Replace the file name with the github object variable that contains the file name being executed.
    if grep -q ".github/workflows/docker_build.yml" "${TMP_CHANGES_FILE}"; then
        echo "** .github/workflows/docker_build.yml changed. Will rebuild all images"
        BASE_IMAGES_TO_BUILD="$BUILDABLE_BASE_IMAGES"
    else
        for base_image in $(echo "$BUILDABLE_BASE_IMAGES" | tr "," "\n"); do
            if grep -q "^$base_image/" "${TMP_CHANGES_FILE}"; then
                BASE_IMAGES_TO_BUILD="${BASE_IMAGES_TO_BUILD} ${base_image}"
            fi
        done

        BASE_IMAGES_TO_BUILD=$(echo -e "$BASE_IMAGES_TO_BUILD" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr " " ",")

        echo "** Will rebuild images: '$BASE_IMAGES_TO_BUILD'"
    fi
elif [[ "${WORKFLOW}" == "workflow_dispatch" ]]; then
    BASE_IMAGES_TO_BUILD=$(echo "$INPUTS_BASE_IMAGES" | tr -d " ")
    echo "WORKFLOW EVENT: Building based on parameters: $BASE_IMAGES_TO_BUILD"
else
    BASE_IMAGES_TO_BUILD="$BUILDABLE_BASE_IMAGES"
    echo "** Will build images: '$BUILDABLE_BASE_IMAGES'"
fi

if [[ -z "$BASE_IMAGES_TO_BUILD" ]]; then
    echo "::error ::Unable to determine base images to build."

    exit 1
else
    echo "::set-output name=base_images_to_build::$BASE_IMAGES_TO_BUILD"
fi
