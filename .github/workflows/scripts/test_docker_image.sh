#!/bin/bash -eu

docker run -t "$DOCKER_IMAGE":"$DOCKER_IMAGE_TAG" ls -alrt /acmesh/
docker run -t "$DOCKER_IMAGE":"$DOCKER_IMAGE_TAG" acme.sh --help

# Check user/group setup scenarios
docker run -t --env PUID=1007 "$DOCKER_IMAGE":"$DOCKER_IMAGE_TAG" id container
docker run -t --env PUID=1007 --env PGID=1008 "$DOCKER_IMAGE":"$DOCKER_IMAGE_TAG" id container
docker run -t --env PGID=1008 "$DOCKER_IMAGE":"$DOCKER_IMAGE_TAG" id container
docker run -t --env PUID=0 --env PGID=1008 "$DOCKER_IMAGE":"$DOCKER_IMAGE_TAG" id root

# Check locking mechanism
mkdir -p /tmp/acmesh
flock --exclusive --nonblock --conflict-exit-code 11 --verbose /tmp/acmesh/run.lock docker run -ti --volume /tmp/acmesh/:/acmesh/config 8117466df461b7f01e825feb5d5383a2bd5a2b39b0e27baa949e7c85498403de acme-lock.sh
