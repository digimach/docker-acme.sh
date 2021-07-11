#!/usr/bin/with-contenv bash
# shellcheck shell=bash

# This cont-init script is responsible for setting the correct permissions on files
# and folders.

set -eu

if [[ $EUID -ne 0 ]]; then
    echo "** Docker container is not started with root user. This is not supported, but will continue."
fi

DIRS_TO_CHECK="$LE_CONFIG_HOME $LE_CERT_HOME"

for dir in $DIRS_TO_CHECK; do
    if [[ $(stat -c %u "$dir") != "$PUID" ]]; then
        chown -R "$PUID":"$PGID" "$dir"
        echo "** Ownership for $dir set to UID: '$PUID'"
    else
        echo "** Ownership for $dir already set to UID: '$PUID'"
    fi
done
