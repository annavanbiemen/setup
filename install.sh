#!/bin/bash

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
echo -e "    🔸 ${bold}ide${reset} to open your IDE in the current project."
echo -e "    🔸 ${bold}py${reset} to start a Python repl with rich colors."
echo

# Read name/email from .env
if [ -f ~/.env ]; then
    # shellcheck source=/dev/null
    source ~/.env
fi
name="${NAME:-}"
email="${EMAIL:-}"

# Read name/email from arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --name) name="$2"; shift ;;
        --email) email="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; usage; exit 1 ;;
    esac
    shift
done

# Read name/email from input
if [ -z "$name" ] || [ -z "$email" ]; then
    echo "  Lets start with a little introduction first."
    echo
    echo "  Please enter your"
    echo
    read -rp "    - Name:  " name
    read -rp "    - Email: " email
    echo
fi

setup="$( dirname "$( realpath "$0")" )"
setup_relative="${setup/"$HOME/"/}"
sourceline=". \"${setup/"$HOME"/"\$HOME"}/env\""
export PATH="$setup/bin:$PATH"

cd ~
append .profile "$sourceline"
append .bashrc "$sourceline"
append .path ".local/bin" && mkdir -p ~/.local/bin
append .path "$setup_relative/bin"
append .env "NAME=\"$name\""
append .env "EMAIL=\"$email\""

echo
echo "  Setup done! 🎉"
echo
echo "  $sourceline # or start a new shell to activate"
echo
