#!/bin/bash

set -euo pipefail

docker build --build-arg TZ="$( cat /etc/timezone )" --tag setup .
docker run -it --rm --env "TERM=${TERM}" --hostname sandbox setup
