# shellcheck shell=bash

# Does configuration file have this line?
#
# Usage: config::has <file> <line>
#
# Arguments:
#   file  Configuration file to check
#   line  Line to check
config::has() {
    # Read arguments
    local file="$1"
    local line="$2"

    if [[ -f "${file}" ]] && grep -qxF "${line}" "${file}"; then
        return 0 # true
    fi

    return 1 # false
}

# Add lines to configuration file (only if not already present)
#
# Usage: config::add <file> <line>...
#
# Arguments:
#   file      Configuration file to add lines to
#   line ...  Lines to add (unless already present) one by one
config::add() {
    # Read arguments
    local file="$1"
    local lines=("${@:2}")

    # Iterate over given lines
    local line
    for line in "${lines[@]}"; do
        # Skip line if already present
        if config::has "${file}" "${line}"; then
            continue
        fi

        # Add line to file
        echo "${line}" >> "${file}"
    done
}
