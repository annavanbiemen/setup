#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")"
mkdir -p log

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
