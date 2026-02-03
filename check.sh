#!/bin/bash

# Exit on errors
set -euo pipefail

# Change directory to the setup home
cd "$(dirname "$0")"

# Lint scripts using bash (and POSIX-compatible dash in case of `env`)
bin/require-apt dash bash
dash -n env
find . -path './.git' -prune -o -type f \( -executable -o -name "*.sh" -o -path './env' \) -exec bash -x -n {} +

# Run shellcheck on all scripts
bin/require-apt shellcheck
find . -path './.git' -prune -o -type f \( -executable -o -name "*.sh" -o -path './env' \) -exec shellcheck -x {} +

# Check shell script formatting using shfmt
bin/require-apt shfmt
shfmt --indent 4 --space-redirects --diff ./*.sh env bin/* lib/*.sh

# Done!
echo "All OK!"
