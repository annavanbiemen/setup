#!/bin/bash

# Exit on errors
set -euo pipefail

# Change directory to the setup home
cd "$(dirname "$0")"

# Create the log directory
mkdir -p log

# Build the setup image
docker build --build-arg TZ="$(cat /etc/timezone)" --tag setup .

echo "Testing recipes:"
for recipe in $(just --summary); do
    printf -- "- %-10s" "${recipe}"
    if docker run -it --rm --env "TERM=${TERM}" --hostname sandbox setup setup/bin/setup "$recipe" &>"log/$recipe.log"; then
        printf "✅ "
    else
        printf "❌ "
    fi
    tail -n1 "log/${recipe}.log" || printf "unable to read log\n"
done
