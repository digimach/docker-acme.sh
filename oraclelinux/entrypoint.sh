#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "** Docker container is not started with root user. This is more secure way of handling this container and this message is only for information."
fi

if [[ "$1" == "_" ]]; then
    shift
    "$@"
elif [[ -z "$1" ]]; then
    acme.sh --help
else
    cd "$LE_WORKING_DIR"
    acme.sh "$@"
fi