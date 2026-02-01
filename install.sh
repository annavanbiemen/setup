#!/bin/bash

# Exit on errors
set -euo pipefail

bold="\e[1m"
reset="\e[0m"

echo
echo "                       ✨ Anna's Setup ✨ "
echo
echo "  Includes:"
echo
echo -e "    🔸 ${bold}env${reset} to load your ~/.env and ~/.path files."
echo -e "    🔸 ${bold}setup${reset} to install your entire dev toolchain."
echo -e "    🔸 ${bold}update${reset} to update everything all at once."
echo -e "    🔸 ${bold}py${reset} to start a Python repl with rich colors."
echo

# Read name and email from .env
if [[ -f ~/.env ]]; then
    # shellcheck source=/dev/null
    source ~/.env
fi
name="${NAME:-}"
email="${EMAIL:-}"

# Read name and email from arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
    --name)
        name="$2"
        shift
        ;;
    --email)
        email="$2"
        shift
        ;;
    *)
        echo "Unknown parameter passed: $1"
        usage
        exit 1
        ;;
    esac
    shift
done

# Read name and email from input
if [[ -z "${name}" ]] || [[ -z "${email}" ]]; then
    echo "  Lets start with a little introduction first."
    echo
    echo "  Please enter your"
    echo
    read -rp "    - Name:  " name
    read -rp "    - Email: " email
    echo
fi

# Determine paths and source line
setup_path="$(dirname "$(realpath "$0")")"
setup_path_relative="${setup_path/"${HOME}/"/}"
setup_source_line=". \"${setup_path/"${HOME}"/"\$HOME"}/env\""

# Add bin directory to PATH
PATH="${setup_path}/bin:${PATH}"

cd ~
append .profile "${setup_source_line}"
append .bashrc "${setup_source_line}"
append .path "${setup_path_relative}/bin"
append .path ".local/bin" && mkdir -p .local/bin
append .env "NAME=\"${name}\""
append .env "EMAIL=\"${email}\""

echo
echo "  Setup done! 🎉"
echo
echo "  ${setup_source_line} # or start a new shell to activate"
echo
