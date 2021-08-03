#!/bin/bash -eu

# Check the acme.sh release to see if this repository has a branch associated with the
# release. If not set the variables new_branch, new_release_version and new_version.

check_release() {
    local release_check_response
    local release_check_return_value
    local release_tag_name

    if [[ "${EVENT_NAME}" == "workflow_dispatch" ]]; then
        # use the input from the workflow as the acme.sh version and validate it.
        echo "** Validating the version from ${ACMESH_VERSION} on acmesh-official/acme.sh"
        release_check_response=$(curl --fail --silent "https://api.github.com/repos/acmesh-official/acme.sh/releases/tags/${ACMESH_VERSION}")
        release_check_return_value=$?

        if [[ $release_check_return_value != 0 ]]; then
            echo "** Release check failed for $ACMESH_VERSION."
            echo "** URL used: https://api.github.com/repos/acmesh-official/acme.sh/releases/tags/${ACMESH_VERSION}"
            exit 1
        fi
    else
        # query acmesh-official/acme.sh repository for the latest version
        echo "** Getting the latest version from acmesh-official/acme.sh"
        release_check_response=$(curl --fail --silent https://api.github.com/repos/acmesh-official/acme.sh/releases/latest)
        release_check_return_value=$?

        if [[ $release_check_return_value != 0 ]]; then
            echo "** Release check failed for latest version."
            echo "** URL used: https://api.github.com/repos/acmesh-official/acme.sh/releases/latest"
            exit 1
        fi
    fi

    release_tag_name=$(echo "$release_check_response" | jq -r ".tag_name")

    echo "** Will check branch for release $release_tag_name"

    # Check if we have a branch associated with that release already
    if ! git branch --all | grep "remotes/origin/stable/$release_tag_name"; then
        echo "** Stable branch for $release_tag_name not found."
        echo "::set-output name=new_branch::stable/$release_tag_name"
        echo "::set-output name=new_release_version::$release_tag_name"
        echo "::set-output name=new_version::true"
    else
        echo "::set-output name=new_version::false"
    fi
}

check_release
