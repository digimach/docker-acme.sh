#!/bin/bash -eu
# generate_matrix_parameters.sh determines the parameters for all the matrix builds
# and downstream jobs.
#
# This script sets two variables, 'date_stamp' and `docker_publish` used by downstream
# jobs.

echo "::set-output name=date_stamp::$(date +'%Y%m%d')"

if [[ $GITHUB_REF =~ refs\/heads\/($LATEST_BRANCH|$STABLE_BRANCH_PREFIX) ]] || [[ "$GITHUB_REF" =~ refs\/tags\/.+ ]]; then
    echo ::set-output name=docker_publish::true
else
    echo ::set-output name=docker_publish::false
fi
