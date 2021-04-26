#!/bin/bash -eu

if [[ $EUID -ne 0 ]]; then
    echo "** Docker container is not started with root user. This is more secure way of handling this container and this message is only for information."
fi

if [[ -z "${1+x}" ]]; then
    acme.sh --help
elif [[ "$1" == "_" ]]; then
    shift
    "$@"
else
    cd "$LE_WORKING_DIR" || exit
    acme.sh "$@"
fi
