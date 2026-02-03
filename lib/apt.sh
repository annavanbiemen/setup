# shellcheck shell=bash

# Require APT packages (optionally from custom sources)
#
# Usage: apt::install [packages] [options]
#
# Arguments:
#   packages  APT packages to install
apt::install() {
    # Collect missing packages
    local missing=()
    local package
    for package in "$@"; do
        if ! dpkg-query -W -f='${Status}' "${package}" 2> /dev/null | grep -q "install ok installed"; then
            missing+=("${package}")
        fi
    done

    # Install missing packages
    if [[ ${#missing[@]} -gt 0 ]]; then
        local -a install_cmd=(sudo DEBIAN_FRONTEND=noninteractive apt-get install --update --yes --no-install-recommends)
        echo -e "\e[1m${install_cmd[*]}" "${missing[@]}" "\e[0m"
        "${install_cmd[@]}" "${missing[@]}"
    fi
}

# Get a GPG key in armored format
#
# Usage: apt::get_key <key_url>
#
# Arguments:
#   key_url  URL to download GPG key from
#
# Returns: Armored GPG key content on stdout
apt::get_key() {
    local key_url="$1"

    # Validate key URL format
    if [[ ! "${key_url}" =~ ^https?:// ]]; then
        standard::raise "Invalid key URL format: ${key_url}. Must start with http:// or https://"
    fi

    # Create temporary GPG homedir
    local gpg_home
    gpg_home=$(mktemp -d)
    # shellcheck disable=SC2064
    trap "rm -rf '${gpg_home}'" EXIT

    # Download key and import into GPG
    curl --proto '=https' --tlsv1.2 -fsSL "${key_url}" |
        gpg --homedir "${gpg_home}" --import

    # Export armored GPG key
    gpg --homedir "${gpg_home}" --export --armor
}

# Add apt source
#
# Usage: apt::add_source <source> [options]
#
# Options:
#   --uri URI              Package URI
#   --key KEY              Key URI
#   --suite-codename       Use current Ubuntu codename as suite
#   --suite SUITE          Suite                    (e.g. 'noble')
#   --component COMPONENT  Component                (e.g. 'stable', 'main')
#   --arch ARCH            Optional architecture    (e.g. 'amd64')
#   --language LANGUAGE    Optional language codes  (e.g. 'en de')
apt::source() {
    # Parse arguments
    local source="$1"
    local uri=""
    local key=""
    local architecture
    local suite="stable"
    local component="main"

    # Detect architecture
    architecture="$(dpkg --print-architecture)"

    shift
    while [[ "$#" -gt 0 ]]; do
        case $1 in
        --uri)
            uri="$2"
            shift
            ;;
        --key)
            key="$2"
            shift
            ;;
        --arch)
            architecture="$2"
            shift
            ;;
        --suite)
            suite="$2"
            shift
            ;;
        --suite-codename)
            suite=$(. /etc/os-release && echo "${UBUNTU_CODENAME:-${VERSION_CODENAME}}")
            ;;
        --component)
            component="$2"
            shift
            ;;
        -*)
            standard::raise "Unknown option passed: $1"
            ;;
        *)
            standard::raise "Unknown argument passed: $1"
            ;;
        esac
        shift
    done

    # Validate required arguments
    if [[ -z "${source}" ]] || [[ -z "${uri}" ]] || [[ -z "${key}" ]] || [[ -z "${component}" ]]; then
        standard::raise "Missing required arguments. You must specify the source, uri, key, and component."
    fi

    # Validate URL format
    if [[ ! "${uri}" =~ ^https?:// ]]; then
        standard::raise "Invalid URI format: ${uri}. Must start with http:// or https://"
    fi

    # Install required packages
    apt::install ca-certificates gpg gpg-agent

    # Get armored GPG key
    local gpg_key_armored
    gpg_key_armored="$(apt::get_key "${key}")"

    # Create the sources file in DEB822 format with the embedded key
    {
        echo "Types: deb"
        echo "URIs: ${uri}"
        echo "Suites: ${suite}"
        echo "Components: ${component}"
        echo "Architectures: ${architecture}"
        echo "Signed-By: |"
        # shellcheck disable=SC2001
        echo "${gpg_key_armored}" | sed 's/^/ /'
    } | sudo tee "/etc/apt/sources.list.d/${source}.sources"
}
