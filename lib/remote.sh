# shellcheck shell=bash

# Get a remote script
#
# Usage: remote::get <url>
#
# Arguments:
#   url  URL of the remote script
remote::get() {
    # Read arguments
    local url="$1"

    # Require packages
    apt::install ca-certificates curl

    # Download script and pipe to the given shell
    curl --proto '=https' --tlsv1.2 --location --silent --show-error --fail "${url}"
}

# Pipe a remote script through a given shell command
#
# Usage: remote::shell [shell] ... <url>
#
# Arguments:
#   shell  Shell to pipe the script to (default: sh)
#   url    URL to fetch the script from
remote::shell() {
    # Read arguments
    local url="${!#}"
    local shell=("sh")
    if [[ $# -gt 1 ]]; then
        shell=("${@:1:$#-1}")
    fi

    remote::get "${url}" | "${shell[@]}"
}
