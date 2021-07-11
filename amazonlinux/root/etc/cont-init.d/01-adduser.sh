#!/usr/bin/with-contenv bash
# shellcheck shell=bash

set -eu

if [[ $EUID -ne 0 ]]; then
    echo "** Docker container is not started with root user. This is not supported, but will continue."
fi

if [[ $PUID != 0 ]]; then
    adduser --no-create-home --home "$LE_CONFIG_HOME" --shell /bin/false --uid "$PUID" container
    echo "** Added user 'container' with UID: '$PUID'"

    if [[ $PGID != 0 && $PGID != "$PUID" ]]; then
        groupadd --gid "$PGID" container_group
        echo "** Added 'container_group' group with GID '$PGID'."
        usermod --append --groups container_group container
        echo "** Added 'container' user to group 'container_group'"
    fi

elif [[ $PGID != 0 ]]; then
    RUNNING_USER="$(getent passwd "$PUID" | cut -d: -f1)"
    groupadd --gid "$PGID" container_group
    echo "** Added 'container' group with GID: '$PGID'."
    usermod --append --group container_group "$RUNNING_USER"
    echo "** Added '$RUNNING_USER' user to group 'container' with GID '$PGID'."
else
    echo "** PUID and/or PGID not set, will not add any user or group."
fi
