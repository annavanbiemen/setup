#!/bin/bash

# Exit on errors
set -euo pipefail

# Change directory to the setup home
cd "$( dirname "$0" )"

# Lint scripts using bash (and POSIX-compatible dash in case of `env`)
bin/require-apt dash bash
dash -n env
find bin lib/*.sh check.sh demo.sh install.sh env -type f -exec bash -x -n {} +

# Run shellcheck on all scripts
bin/require-apt shellcheck
find bin lib/*.sh check.sh demo.sh install.sh env justfile -type f -exec shellcheck -x {} +

# Check formatting of the justfile
bin/require-apt just
just --check --fmt --unstable

# Done!
echo "All OK!"
