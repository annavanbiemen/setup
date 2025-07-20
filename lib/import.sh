# shellcheck shell=bash

# Setup import library by Anna van Biemen
#
# Functions:
#   import::loaded [module]
#   import::import <module>
#   import::from <module> import <function> [<function> ...]


# Initialize variables
__import_path="$( dirname "${BASH_SOURCE[0]}" )"
__import_loaded=( "${__import_loaded[@]}" )


# Check if a module is loaded.
#
# Usage: import::loaded [module]
#
# Arguments:
#   module  Module name (default: import)
#
# Returns 1 if the module is not loaded.
import::loaded() {
    # No argument implies the import module itself
    [[ $# -eq 0 ]] && return

    # Read arguments
    [[ $# -eq 1 ]] || return 1
    local module="$1"

    # Check if module is in the __import_loaded array
    [[ " ${__import_loaded[*]} " =~ [[:space:]]${module}[[:space:]] ]] || return 1
}

# Import a module if not yet loaded.
#
# Usage: import::import <module>
#
# Arguments:
#   module  Module name
import::import() {
    [[ $# -eq 1 ]] || return 1
    local module="$1"

    # Import only once
    # shellcheck source=/dev/null
    import::loaded "$module" || source "${__import_path}/${module}.sh"

    # Add module to the __import_loaded array
    __import_imported+=("$module")
}

# Import functions as aliases from module
#
# Usage: import::from <module> import <function> [<function> ...]
#
# Arguments:
#   module    Module name
#   function  Function name to alias from module::
import::from() {
    local module="$1"
    local operation="$2"
    local functions=("${@:3}")

    [[ "${#functions[@]}" -gt 0 ]] || raise echo "from: No function arguments given"
    [[ "$operation" == "import" ]] || raise echo "from: Second argument must be 'import'"

    local function
    import::import "$module"
    for function in "${functions[@]}"; do
        eval "function ${function} { ${module}::${function} \"\$@\"; }"
    done
}
