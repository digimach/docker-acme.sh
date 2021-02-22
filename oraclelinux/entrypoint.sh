#!/bin/bash

if [[ "$1" == "_" ]]; then
    shift
    "$@"
elif [[ -z "$1" ]]; then
    acme.sh --help
else
    acme.sh "$@"
fi
