#!/bin/bash

# Exit on errors
set -euo pipefail

# Change directory to the setup home
cd "$(dirname "$0")"

# Lint scripts using bash (and POSIX-compatible dash in case of `env`)
bin/require-apt dash bash
dash -n env
find . -maxdepth 1 -name '*.sh' -type f -exec bash -x -n {} +
find bin -type f -exec bash -x -n {} +
find lib -name '*.sh' -type f -exec bash -x -n {} +
bash -x -n env

# Run shellcheck on all scripts
#bin/require-apt shellcheck
find . -maxdepth 1 -name '*.sh' -type f -exec shellcheck -x {} +
find bin -type f -exec shellcheck -x {} +
find lib -name '*.sh' -type f -exec shellcheck -x {} +
shellcheck -x env

# Check shell script formatting using shfmt
bin/require-apt shfmt
shfmt --indent 4 --space-redirects --diff ./*.sh env bin/* lib/*.sh

# Done!
echo "All OK!"
