#!/bin/bash -eu
# get_base_images determines what base OS are buildable and which of those should be
# built.
# This script sets two variables, 'base_images_to_build' and `buildable_base_images`
# used by downstream jobs.

echo "** Getting base images to build as part of this action"

BUILDABLE_BASE_IMAGES=$(find . -mindepth 1 -maxdepth 1 -type d -not -name ".*" -printf '%f\n' | paste -d, -s -)
echo "::set-output name=buildable_base_images::$BUILDABLE_BASE_IMAGES"

TMP_CHANGES_FILE="$(mktemp)"
BASE_IMAGES_TO_BUILD=""

if [[ "${EVENT_NAME}" == "pull_request" ]]; then
    # If this is a pull request, we build only what is needed. This is done by diffing
    # what has changed and based on the root folder the relevant base OS will be
    # built.

    echo "** This is a pull request. Will do a differential build only"

    TMP_CHANGES_FILE="$(mktemp)"
    git fetch origin "$BUILD_REF"
    git log -1 FETCH_HEAD

    # Push event - retrieve list of changed files
    git diff --name-only "remotes/origin/$BASE_REF..FETCH_HEAD" >"${TMP_CHANGES_FILE}"

    echo "** Files changed:"
    cat "${TMP_CHANGES_FILE}"

    # TODO: Replace the file name with the github object variable that contains the file name being executed.
    if grep -q ".github/workflows/" "${TMP_CHANGES_FILE}"; then
        echo "** .github/workflows/ changed. Will rebuild all images"
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
elif [[ "${EVENT_NAME}" == "workflow_dispatch" ]]; then
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
