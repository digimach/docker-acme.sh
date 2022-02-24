#!/bin/bash -eu
# get_parameters.sh determines what acme.sh version to build and the docker image tags.
#
# This script sets two variables, 'acmesh_version', 'tag' and 'acmesh_stable_version'
# used by downstream jobs.

acmesh_latest_stable_version() {
    STABLE_ACMESH_VERSION=$(git branch --all | grep "remotes/origin/stable/" | cut --fields=4 --delimiter="/" | sort | tail --lines 1)

    if [ -z "$STABLE_ACMESH_VERSION" ]; then
        echo "** Unable to determine STABLE_ACMESH_VERSION from git branch --all"
        git branch --all
        exit 1
    fi
}

get_parameters() {
    echo "** Will determine acme.sh version and Docker tags"

    STABLE_BRANCH_PREFIX_ESCAPED=$(sed 's/[^^]/[&]/g; s/\^/\\^/g' <<<"$STABLE_BRANCH_PREFIX")

    if [[ "$GITHUB_REF" == refs/heads/$LATEST_BRANCH ]]; then
        # acme.sh uses master branch names, but we use main. While getting the artifacts
        # from acme.sh we use master.
        ACMESH_VERSION="$LATEST_ACMESH_VERSION"
        # Tag Format: <base_os>-<acmesh-version>-<date-stamp>-<platform>
        DOCKER_IMAGE_TAG="${BASE_IMAGE}-${ACMESH_VERSION}-${DATE_STAMP}-$(echo "${PLATFORM}" | tr '/' '_')-${GITHUB_RUN_ID}"
    elif [[ "$GITHUB_REF" =~ refs\/heads\/$STABLE_BRANCH_PREFIX_ESCAPED ]]; then
        ACMESH_VERSION="${GITHUB_REF#refs/heads/$STABLE_BRANCH_PREFIX_ESCAPED}"
        # Tag Format: <base_os>-<acmesh-version>-<date-stamp>-<platform>
        DOCKER_IMAGE_TAG="${BASE_IMAGE}-${ACMESH_VERSION}-${DATE_STAMP}-$(echo "${PLATFORM}" | tr '/' '-')-${GITHUB_RUN_ID}"
    elif [[ "$GITHUB_REF" =~ refs\/tags\/v.+ ]]; then
        # acme.sh doesn't tag with a prefix v, but this repo does. So we drop the v when
        # getting the artifacts from acme.sh and also tag without the v in docker images
        ACMESH_VERSION="${GITHUB_REF#refs/tags/v}"
        DOCKER_IMAGE_TAG="${BASE_IMAGE}-${ACMESH_VERSION}-${DATE_STAMP}-$(echo "${PLATFORM}" | tr '/' '-')-${GITHUB_RUN_ID}"
    elif [[ $GITHUB_EVENT_NAME == "pull_request" ]]; then
        PULL_REQUEST_NUMBER=$(echo "$GITHUB_REF" | cut -f3 -d"/")

        if [[ $GITHUB_BASE_REF == "$LATEST_BRANCH" ]]; then
            echo "** Pull Request is based on latest branch $GITHUB_BASE_REF will use $LATEST_ACMESH_VERSION"
            ACMESH_VERSION="$LATEST_ACMESH_VERSION"
        elif [[ $GITHUB_BASE_REF == "$STABLE_BRANCH" ]]; then
            echo "** Pull Request is based on stable branch $GITHUB_BASE_REF will use $STABLE_ACMESH_VERSION"
            ACMESH_VERSION="$STABLE_ACMESH_VERSION"
        else
            echo "** Pull Request is based on $GITHUB_BASE_REF branch and no rule for acme version set, will use $LATEST_ACMESH_VERSION"
            ACMESH_VERSION="${GITHUB_BASE_REF}"
        fi
        # Tag Format: <base_os>-<acmesh-version>-<date-stamp>-<platform>-pr<pr_number>
        DOCKER_IMAGE_TAG="${BASE_IMAGE}-${ACMESH_VERSION}-${DATE_STAMP}-$(echo "${PLATFORM}" | tr '/' '_')-pr${PULL_REQUEST_NUMBER}s"
    else
        echo "** No rule defined for this build in order to get parameters."
        exit 1
    fi

    echo ::set-output name=tag::"$DOCKER_IMAGE_TAG"
    echo ::set-output name=acmesh_version::"$ACMESH_VERSION"
    echo ::set-output name=acmesh_stable_version::"$STABLE_ACMESH_VERSION"
}

acmesh_latest_stable_version
get_parameters
