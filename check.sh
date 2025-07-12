#!/bin/bash

set -euo pipefail

cd "$( dirname "$0")"
bin/require-apt shellcheck
find bin etc check.sh demo.sh install.sh -type f -executable -exec shellcheck -x {} +
just --check --fmt --unstable
echo "All OK!"
