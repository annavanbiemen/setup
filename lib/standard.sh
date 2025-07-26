# shellcheck shell=bash

# Setup main library by Anna van Biemen
#
# Functions:
#   standard::error [message]
#   standard::raise [command]
#   standard::trace
#   standard::debug
#   standard::with <option>
#   standard::usage <function>
#   standard::version

# Output an error
#
# Usage: standard::error [message]
#
# Arguments:
#   message  Message text
standard::error() {
    local text="$1"

    printf "ERROR: %s" "${text}" >&2
}

# Raise non-zero exit code and output from optional command to STDERR
#
# Usage: standard::raise [command]
#
# Arguments:
#   command  Optional command to run, output gets redirected to STDERR
#
# Returns non-zero exit code returned from command or 1 otherwise
standard::raise() {
    if [[ "$#" -gt 0 ]]; then
        "$@" >&2 || return $?
    fi

    return 1
}

# Print trace including arguments (if extdebug was enabled)
#
# Usage: standard::trace
standard::trace() {
    printf "\n\e[4mTrace\e[0m\n"
    local frame arg arg_count arg_pos=${BASH_ARGC[0]} file line call
    for ((frame = 1; frame < ${#FUNCNAME[@]}; frame++)); do
        arg_count=${BASH_ARGC[frame]}
        arg_pos=$((arg_pos + arg_count))

        file="${BASH_SOURCE[${frame}]}"
        line="${BASH_LINENO[$((frame - 1))]}"
        call="${FUNCNAME[frame]}"
        for ((arg = 1; arg <= arg_count; arg++)); do
            call+=$(printf " %q" "${BASH_ARGV[arg_pos - arg]}")
        done

        printf "%2d %-30s  # %s:%s\n" "${frame}" "${call}" "${file}" "${line}"
    done
}

# Enable extdebug to keep track of arguments and handle ERR exit using a trace
#
# Usage: standard::debug
standard::debug() {
    shopt -s extdebug
    trap standard::trace ERR
}

# Run command with option enabled
#
# Usage: standard::with <option> <command>
#
# Arguments:
#   option   Option to enable (temporarily) while executing the command
#   command  Command to run while the option is enabled
standard::with() {
    local option="$1"
    shift

    if shopt -p "${option}" > /dev/null; then
        "$@"
        return $?
    fi

    local exit=0
    shopt -s "${option}" > /dev/null
    "$@" || exit=$?
    shopt -u "${option}" > /dev/null

    return "${exit}"
}

# Show usage information for a function
#
# Usage: standard::usage [function]
#
# Arguments
#   function  Function to display usage for
standard::usage() {
    # Read arguments
    [[ $# -le 1 ]] || return 1
    local function="${1:-main}"

    # Determine file where function was defined
    local info file
    IFS=" " read -r -a info <<< "$(standard::with extdebug declare -F "${function}")"
    file="${info[2]}"

    # Use awk to parse the usage information
    awk -v func="${function}" '
    $0 ~ "^(function[[:space:]]+)?" func "[[:space:]]*\\([[:space:]]*\\)" {
        if (comment_block) {
            # Print the stored comments, removing the final newline
            printf "%s", substr(comment_block, 1, length(comment_block))
        }
        exit
    }
    /^[[:space:]]*#/ {
        line = $0
        sub(/^[[:space:]]*#[[:space:]]?/, "", line)
        comment_block = comment_block line "\n"
        next
    }
    /./ {
        comment_block = ""
    }
    ' "${file}"
}

# Show version information
#
# Usage: standard::version
standard::version() {
    git -C "$(dirname "$0")" describe --always --dirty
}
