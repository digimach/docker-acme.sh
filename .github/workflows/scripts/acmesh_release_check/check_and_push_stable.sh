#!/bin/bash -eu

# Check the acme.sh release to see if this repository has a branch associated with the
# release. If not create the branch.
# When running workflow as workflow_dispatch use the provided acme.sh version.

check_release() {
    local release_check_response
    local release_check_return_value
    local release_tag_name

    if [[ "${EVENT_NAME}" == "workflow_dispatch" ]]; then
        release_check_response=$(curl --fail --silent "https://api.github.com/repos/acmesh-official/acme.sh/releases/tags/${ACMESH_VERSION}")
        release_check_return_value=$?

        if [[ $release_check_return_value != 0 ]]; then
            echo "** Release check failed for $ACMESH_VERSION."
            echo "** URL used: https://api.github.com/repos/acmesh-official/acme.sh/releases/tags/${ACMESH_VERSION}"
            exit 1
        fi
    else
        release_check_response=$(curl --fail --silent https://api.github.com/repos/acmesh-official/acme.sh/releases/latest)
        release_check_return_value=$?

        if [[ $release_check_return_value != 0 ]]; then
            echo "** Release check failed for latest version."
            echo "** URL used: https://api.github.com/repos/acmesh-official/acme.sh/releases/latest"
            exit 1
        fi
    fi

    release_tag_name=$(echo "$release_check_response" | jq -r ".tag_name")
    push_stable "$release_tag_name"

}

push_stable() {
    local release_tag=$1

    if ! git branch --all | grep "remotes/origin/stable/$release_tag"; then
        git checkout main
        echo "** Tag $release_tag not found will create stable/$release_tag from main"
        git push origin "main:stable/$release_tag"
        echo "::set-output name=new_branch::stable/$release_tag"
        echo "::set-output name=new_release_version::$release_tag"
        echo "::set-output name=new_version::true"
    else
        echo "::set-output name=new_version::false"
    fi
}

check_release
