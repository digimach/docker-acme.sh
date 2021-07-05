#!/usr/bin/with-contenv bash
# shellcheck shell=bash

# This cont-init script is responsible for creating the directory structure required
# for the container application to function.

set -eu

if [[ $EUID -ne 0 ]]; then
    echo "** Docker container is not started with root user. This is not supported, but will continue."
fi

DIRS_TO_CREATE="$LE_CONFIG_HOME $LE_CERT_HOME $LE_CONFIG_HOME/data"

for dir in $DIRS_TO_CREATE; do
    if [ -d "$dir" ]; then
        echo "** Directory $dir exists. Will not create."
    else
        mkdir -p "$dir"
        chown "$PUID":"$PGID" "$dir"
        echo "** Directory $dir created."
    fi
done
