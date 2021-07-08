#!/bin/bash -eu

# Basic starting point checks
cmd="docker run -t $DOCKER_IMAGE:$DOCKER_IMAGE_TAG ls -alrt /acmesh/"
echo "** Running '$cmd'"
eval "$cmd"

cmd="docker run -t $DOCKER_IMAGE:$DOCKER_IMAGE_TAG acme.sh --help"
echo "** Running '$cmd'"
eval "$cmd"

# Check user/group setup scenarios
cmd="docker run -t --env PUID=1007 $DOCKER_IMAGE:$DOCKER_IMAGE_TAG id container"
echo "** Running '$cmd'"
eval "$cmd"

cmd="docker run -t --env PUID=1007 --env PGID=1008 $DOCKER_IMAGE:$DOCKER_IMAGE_TAG id container"
echo "** Running '$cmd'"
eval "$cmd"

cmd="docker run -t --env PGID=1008 $DOCKER_IMAGE:$DOCKER_IMAGE_TAG id container"
echo "** Running '$cmd'"
eval "$cmd"

cmd="docker run -t --env PUID=0 --env PGID=1008 $DOCKER_IMAGE:$DOCKER_IMAGE_TAG id root"
echo "** Running '$cmd'"
eval "$cmd"

# Check locking mechanism
rm -rf /tmp/acmesh
mkdir -p /tmp/acmesh
set +e
cmd="flock --exclusive --nonblock --conflict-exit-code 11 --verbose /tmp/acmesh/run.lock docker run -t --volume /tmp/acmesh/:/acmesh/config $DOCKER_IMAGE:$DOCKER_IMAGE_TAG acme.sh"
echo "** Running '$cmd'"
eval "$cmd"
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "---- Error code was found as expected"
else
    echo "---- Did not exit with error code. Failing!"
    exit 1
fi
set -e

# Check daemon
## Check default daemon launch
set -x
rm -rf /tmp/acmesh
mkdir -p /tmp/acmesh/
docker rm -f acmesh-renewal-daemon
docker run --name acmesh-renewal-daemon -d --env ACMESH_DAEMON=1 --env LE_LOG_DIR=/srv/acmesh/logs --volume /tmp/acmesh/:/srv/acmesh/ "$DOCKER_IMAGE":"$DOCKER_IMAGE_TAG"
while [ ! -f /tmp/acmesh/logs/acmesh-renewal/current ]; do sleep 1; done
sleep 5

if ! grep "Launching acme.sh renewal daemon" /tmp/acmesh/logs/acmesh-renewal/current; then
    echo "---- Unable to find string 'Launching acme.sh renewal daemon'"
    exit 1
else
    echo "---- Found 'Launching acme.sh renewal daemon'"
fi

if ! grep "Renewal check and renewal of certificate(s) if any completed!" /tmp/acmesh/logs/acmesh-renewal/current; then
    echo "---- Unable to find string 'Renewal check and renewal of certificate(s) if any completed!'"
    exit 1
else
    echo "---- Found 'Renewal check and renewal of certificate(s) if any completed!'"
fi

if ! grep "Will perform next check and renewal in 1h" /tmp/acmesh/logs/acmesh-renewal/current; then
    echo "---- Unable to find string 'Will perform next check and renewal in 1h'"
    exit 1
else
    echo "---- Found 'Will perform next check and renewal in 1h'"
fi

docker rm --force acmesh-renewal-daemon

## Check daemon launch with provided renewal frequency variable
rm -rf /tmp/acmesh1
mkdir -p /tmp/acmesh1
docker run --name acmesh-renewal-daemon -d --env ACMESH_DAEMON=1 --env LE_LOG_DIR=/srv/acmesh/logs --env RENEWAL_CHECK_FREQUENCY=2h --volume /tmp/acmesh1:/srv/acmesh "$DOCKER_IMAGE":"$DOCKER_IMAGE_TAG"
while [ ! -f /tmp/acmesh1/logs/acmesh-renewal/current ]; do sleep 1; done
sleep 5

if ! grep "Will perform next check and renewal in 2h" /tmp/acmesh1/logs/acmesh-renewal/current; then
    echo "---- Unable to find string 'Will perform next check and renewal in 2h'"
    exit 1
else
    echo "---- Found 'Will perform next check and renewal in 2h'"
fi

docker rm --force acmesh-renewal-daemon
