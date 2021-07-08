#!/usr/bin/with-contenv bash
# shellcheck shell=bash

# This service script is the acme.sh renewal daemon that performs the renewal check
# and certificate renewals at a given frequency.

set -eu

echo "** Launching acme.sh renewal daemon."
RENEWAL_CHECK_FREQUENCY="${RENEWAL_CHECK_FREQUENCY:-1h}"
LOCKFILE="$LE_CONFIG_HOME/run.lock"
TERMINATE_LOOP=0

signal_term() {
    # function to run when signals are trapped which require the daemon to be
    # terminated.
    echo "** Processing termination signal."
    TERMINATE_LOOP=1
    if [[ $sleep_pid -ne "" ]]; then
        echo "** Killing sleep!"
        kill -9 "$sleep_pid"
    fi
}

renewal_loop() {
    # Function that initiates a loop with sleep intervals that calls acme.sh to
    # check and renew certificates.

    # notify the file descriptor defined in notification-fd that the service is ready
    printf 'acme.sh renewal daemon is ready!\n' >&3

    while true; do
        sleep_pid=""
        echo "** Performing renewal checks and if needed will renew certificates."
        set +e
        flock -x -n "$LOCKFILE" "$LE_WORKING_DIR/acme.sh" --renew-all --log
        retVal=$?
        set -e

        if [ $retVal -ne 0 ]; then
            echo "** Renewal check or renewal of certificate(s) failed with error(s)!"
        else
            echo "** Renewal check and renewal of certificate(s) if any completed!"
        fi

        if [[ "$TERMINATE_LOOP" == 1 ]]; then
            echo "** Preparing to terminate acme.sh renewal daemon."
            break
        fi

        echo "** Will perform next check and renewal in $RENEWAL_CHECK_FREQUENCY"
        sleep "$RENEWAL_CHECK_FREQUENCY" &
        sleep_pid=$!
        wait "$sleep_pid"
    done

}

trap signal_term SIGINT SIGTERM

renewal_loop

echo "** Exiting daemon!"
