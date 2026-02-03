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
        export DEBIAN_FRONTEND=noninteractive
        local command="sudo apt-get install --update --yes --no-install-recommends"
        echo -e "\e[1m${command}" "${missing[@]}" "\e[0m"
        ${command} "${missing[@]}"
    fi
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
    if [[ ! "${key}" =~ ^https?:// ]]; then
        standard::raise "Invalid key URL format: ${key}. Must start with http:// or https://"
    fi

    # Download the GPG key into a variable ---
    apt::install ca-certificates gpg gpg-agent
    echo "Downloading GPG key from ${key}..."
    local gpg_home
    gpg_home=$(mktemp -d)
    # shellcheck disable=SC2064
    trap "rm -rf '${gpg_home}'" EXIT
    local GPG_KEY_ORIGINAL="${gpg_home}/key.gpg"
    local GPG_KEY_ARMORED="${gpg_home}/key.asc"
    curl --proto '=https' --tlsv1.2 -fsSL "${key}" > "${GPG_KEY_ORIGINAL}"
    gpg --homedir "${gpg_home}" --import "${GPG_KEY_ORIGINAL}"
    gpg --homedir "${gpg_home}" --export --armor > "${GPG_KEY_ARMORED}"

    # Create the sources file in DEB822 format with the embedded key
    {
        echo "Types: deb"
        echo "URIs: ${uri}"
        echo "Suites: ${suite}"
        echo "Components: ${component}"
        echo "Architectures: ${architecture}"
        echo "Signed-By: |"
        sed 's/^/ /' "${GPG_KEY_ARMORED}"
    } | sudo tee "/etc/apt/sources.list.d/${source}.sources"
}
