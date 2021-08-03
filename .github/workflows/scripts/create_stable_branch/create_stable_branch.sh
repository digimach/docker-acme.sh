#!/bin/bash -eu
# Push a stable branch up to the repository based of head of main branch.
# Provide the new_branch_name as the first argument to this script.

push_new_branch_from_main() {
    local new_branch_name=$1

    git checkout main
    git add --update
    git config user.name digimach-auto
    git config user.email digimach-auto-noreply@digimach.com
    git add --update
    git commit -m "Creating $new_branch_name"
    git push origin "main:$new_branch_name"
}

new_branch_name="$1"
push_new_branch_from_main "$new_branch_name"
