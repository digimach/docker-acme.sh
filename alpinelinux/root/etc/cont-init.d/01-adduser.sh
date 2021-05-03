#!/usr/bin/with-contenv bash

set -eu

if [[ $EUID -ne 0 ]]; then
    echo "** Docker container is not started with root user. This is not supported, but will continue."
fi

if [[ $PUID != 0 ]]; then
    adduser -HD -h "${LE_CONFIG_HOME}" -s /bin/false --uid "$PUID" container
    echo "** Added user 'container' with UID: '$PUID'"

    if [[ $PGID != 0 && $PGID != "$PUID" ]]; then
        addgroup -g "$PGID" container_group
        echo "** Added 'container_group' group with GID '$PGID'."
        usermod -G container_group container
        echo "** Added 'container' user to group 'container_group'"
    fi

elif [[ $PGID != 0 ]]; then
    RUNNING_USER="$(getent passwd "$PUID" | cut -d: -f1)"
    addgroup -g "$PGID" container_group
    echo "** Added 'container' group with GID: '$PGID'."
    addgroup "$RUNNING_USER" container_group
    echo "** Added '$RUNNING_USER' user to group 'container' with GID '$PGID'."
else
    echo "** PUID and/or PGID not set, will not add any user or group."
fi
