#!/bin/bash -eu

# Check the acme.sh release to see if this repository has a branch associated with the
# release. If not create the branch.

latest_release_tag_name=$(curl https://api.github.com/repos/acmesh-official/acme.sh/releases/latest | jq -r ".tag_name")

if ! git branch --all | grep "remotes/origin/stable/$latest_release_tag_name"; then
    git checkout main
    echo "** Tag $latest_release_tag_name not found will create stable/$latest_release_tag_name from main"
    git push origin main:stable/$latest_release_tag_name
    echo "::set-output name=new_version::true"
fi