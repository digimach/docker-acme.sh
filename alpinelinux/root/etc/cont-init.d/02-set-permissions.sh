#!/usr/bin/with-contenv bash
# shellcheck shell=bash

set -eu

if [[ $EUID -ne 0 ]]; then
    echo "** Docker container is not started with root user. This is not supported, but will continue."
fi

if [[ $(stat -c %u "$LE_CONFIG_HOME") != "$PUID" ]]; then
    chown -R "$PUID":"$PGID" "$LE_CONFIG_HOME"
    echo "** Ownership for $LE_CONFIG_HOME set to UID: '$PUID'"
else
    echo "** Ownership for $LE_CONFIG_HOME already set to UID: '$PUID'"
fi

if [[ $(stat -c %u "$LE_CERT_HOME") != "$PUID" ]]; then
    chown -R "$PUID":"$PGID" "$LE_CERT_HOME"
    echo "** Ownership for $LE_CERT_HOME set to UID: '$PUID'"
else
    echo "** Ownership for $LE_CERT_HOME already set to UID: '$PUID'"
fi