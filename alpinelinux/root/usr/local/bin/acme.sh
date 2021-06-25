#!/bin/bash -ue

LOCKFILE="$LE_CONFIG_HOME/run.lock"

flock -x -n "$LOCKFILE" exec s6-setuidgid "$PUID":"$PGID" "$LE_WORKING_DIR/acme.sh" "$@"
