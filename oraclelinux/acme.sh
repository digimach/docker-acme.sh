#!/bin/bash

cd "$ACMESH_INSTALL_DIR" || exit

./acme.sh "$@"
