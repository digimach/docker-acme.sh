#!/usr/bin/with-contenv bash
# shellcheck shell=bash

# This service script is the acme.sh renewal daemon that performs the renewal at a
# given frequency.

set -eu

echo "** Launching acme.sh renewal daemon"
RENEWAL_CHECK_FREQUENCY="${RENEWAL_CHECK_FREQUENCY:-1h}"
LOCKFILE="$LE_CONFIG_HOME/run.lock"

while true; do
    echo "** Performing Renewal Check."
    flock -x -n "$LOCKFILE" "$LE_WORKING_DIR/acme.sh" --renew-all --log
    echo "** Renewal check completed. Will perform next one in $RENEWAL_CHECK_FREQUENCY"
    sleep "$RENEWAL_CHECK_FREQUENCY"
done
