#!/command/with-contenv bash
# shellcheck shell=bash

set -eu

ACMESH_ARTIFACTS_DIR=/opt/acmesh

cd "$ACMESH_ARTIFACTS_DIR"

./acme.sh --install --no-cron --no-profile --auto-upgrade 0

chmod -R +x "$LE_WORKING_DIR"