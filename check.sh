#!/bin/bash

# Exit on errors
set -euo pipefail

# Change directory to the setup home
cd "$(dirname "$0")"

# Import libraries
source "./lib/apt.sh"

# Lint scripts using bash (and POSIX-compatible dash in case of `env`)
apt::install dash bash
dash -n env
find . -path './.git' -prune -o -type f \( -executable -o -name "*.sh" -o -path './env' \) -exec bash -x -n {} ';'

# Run shellcheck on all scripts
apt::install shellcheck
find . -path './.git' -prune -o -type f \( -executable -o -name "*.sh" -o -path './env' \) -exec shellcheck -x {} +

# Check shell script formatting using shfmt
apt::install shfmt
shfmt --indent 4 --space-redirects --diff ./*.sh env bin/* lib/*.sh

# Done!
echo "All OK!"
