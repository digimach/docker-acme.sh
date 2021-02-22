#!/bin/bash -u

cd "$ACMESH_ARTIFACTS_DIR" || exit

"$ACMESH_ARTIFACTS_DIR/acme.sh" "$@"
