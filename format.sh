#!/bin/bash
# Format shell scripts using shfmt
#
# Usage: ./format.sh
#
# Formats all shell scripts in the repository with consistent indentation
# and spacing. Uses 4-space indentation and space redirects.

# Exit on errors
set -euo pipefail

# Change directory to the setup home
cd "$(dirname "$0")"

# Import libraries
source "./lib/apt.sh"

# Format shell scripts using shfmt
apt::install shfmt
find . -path './.git' -prune -o -type f \( -executable -o -name "*.sh" -o -path './env' \) -exec shfmt --indent 4 --space-redirects --write {} +

# Done!
echo "Done!"
