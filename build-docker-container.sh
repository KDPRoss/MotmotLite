#!/usr/bin/env bash

set -eo pipefail

echo "Starting container ..."
docker run --detach --name motmot-builder --tty alpine:3

# Use this instead of `--format json` for compatibility with
# old Docker (e.g., on Debian).
CONTAINER_ID="$( docker ps --format "{{ json .}}" | jq 'select( .Names == "motmot-builder" ) | .ID' | tr -d '"' )"

if [ -z ${CONTAINER_ID+x} ]; then
  echo "Failed to find container ID!"
  exit 1
else
  echo "Container has ID \"$CONTAINER_ID\"."
fi

echo "Copying builder script into the container ..."
docker cp dockerise.sh "$CONTAINER_ID":/dockerise.sh

echo "Making the script executable ..."
docker exec "$CONTAINER_ID" chmod a+x /dockerise.sh

echo "Running the script ..."
docker exec "$CONTAINER_ID" /dockerise.sh

echo "Removing the script ..."
docker exec "$CONTAINER_ID" rm -f /dockerise.sh

echo "Exporting the container ..."
rm -f motmot-lite-docker.tgz
docker export "$CONTAINER_ID" | gzip > motmot-lite-docker.tgz

echo "Stopping the container ..."
docker stop "$CONTAINER_ID"
docker rm "$CONTAINER_ID"

echo "Done."
