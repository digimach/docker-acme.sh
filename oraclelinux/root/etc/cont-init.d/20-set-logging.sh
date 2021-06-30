#!/usr/bin/with-contenv bash
# shellcheck shell=bash

# This cont-init will only be applied if ACMESH_DAEMON is set to "1" which implies
# running the acme.sh renewal daemon. This script is responsible for setting up
# logging prerequisites.

set -eu

if [ -v ACMESH_DAEMON ] && [[ $ACMESH_DAEMON == "1" ]]; then
    echo "** Setting up logging for daemon"

    if ! [ -v S6_LOGGING_SCRIPT ]; then
        printf 'n30 s10000000 S15000000 T !"gzip -nq9"' >/var/run/s6/container_environment/S6_LOGGING_SCRIPT
    fi

    mkdir -p "$LE_LOG_DIR"
    chown -R nobody "$LE_LOG_DIR"
    chmod -R o+w "$LE_LOG_DIR"
fi
