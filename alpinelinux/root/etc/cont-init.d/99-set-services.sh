#!/usr/bin/with-contenv bash
# shellcheck shell=bash

# This cont-init script will remove the service directory if the daemon is not being
# run allowing user invoked commands to run without having the services spawned.

set -eu

if [[ $EUID -ne 0 ]]; then
    echo "** Docker container is not started with root user. This is not supported, but will continue."
fi

if [ -v ACMESH_DAEMON ] && [[ $ACMESH_DAEMON == "1" ]]; then
    echo "** Keeping /etc/services.d files"
else
    echo '** Will not run service and removing /etc/services.d'
    rm -rf /etc/services.d/*
fi
