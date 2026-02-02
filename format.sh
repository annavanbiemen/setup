#!/bin/bash

# Exit on errors
set -euo pipefail

# Change directory to the setup home
cd "$(dirname "$0")"

# Format shell scripts using shfmt
bin/require-apt shfmt
shfmt --indent 4 --space-redirects --write ./*.sh bin/* lib/*.sh env

# Done!
echo "Done!"
