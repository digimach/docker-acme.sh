#!/bin/bash -eu

docker run -t "$DOCKER_IMAGE":"$DOCKER_IMAGE_TAG" ls -alrt /acmesh/
docker run -t "$DOCKER_IMAGE":"$DOCKER_IMAGE_TAG" acme.sh --help

# Check user/group setup scenarios
docker run -t --env PUID=1007 "$DOCKER_IMAGE":"$DOCKER_IMAGE_TAG" id container
docker run -t --env PUID=1007 --env PGID=1008 "$DOCKER_IMAGE":"$DOCKER_IMAGE_TAG" id container
docker run -t --env PGID=1008 "$DOCKER_IMAGE":"$DOCKER_IMAGE_TAG" id container
docker run -t --env PUID=0 --env PGID=1008 "$DOCKER_IMAGE":"$DOCKER_IMAGE_TAG" id root