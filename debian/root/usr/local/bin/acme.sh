#!/bin/bash -ue

exec s6-setuidgid "$PUID":"$PGID" "$LE_WORKING_DIR/acme.sh" "$@"
