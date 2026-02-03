#!/bin/bash

# Exit on errors
set -euo pipefail

# Change directory to the setup home
cd "$(dirname "$0")"

# Format shell scripts using shfmt
bin/require-apt shfmt
find . -path './.git' -prune -o -type f \( -executable -o -name "*.sh" -o -path './env' \) -exec shfmt --indent 4 --space-redirects --write {} +

# Done!
echo "Done!"
