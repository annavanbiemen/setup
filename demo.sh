#!/bin/bash
# Run an interactive demo shell in a Docker container
#
# Usage: ./demo.sh
#
# Builds a Docker image and launches an interactive bash shell
# for testing and demonstrating the setup scripts.

# Exit on errors
set -euo pipefail

# Build the setup image
docker build --build-arg TZ="$(cat /etc/timezone)" --tag setup .

# Run an interactive bash shell in a container using the setup image
docker run -it --rm --env "TERM=${TERM}" --hostname sandbox setup
