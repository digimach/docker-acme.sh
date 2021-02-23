#!/bin/bash -u

cd "$LE_WORKING_DIR" || exit

"$LE_WORKING_DIR/acme.sh" "$@"
