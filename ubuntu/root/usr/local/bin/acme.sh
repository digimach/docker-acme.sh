#!/bin/bash -ue

LOCKFILE="$LE_CONFIG_HOME/run.lock"

flock --exclusive --nonblock --conflict-exit-code 11 --verbose "$LOCKFILE" exec s6-setuidgid "$PUID":"$PGID" "$LE_WORKING_DIR/acme.sh" "$@"
