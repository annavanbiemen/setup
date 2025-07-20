# shellcheck shell=bash disable=SC2016

# Print usage by default
@_default:
    echo "Usage: setup <recipe> [ <recipe> ... ]"
    echo
    # shellcheck disable=all
    "{{ just_executable() }}" --justfile "{{ justfile() }}" --list

# https://github.com/Azure/azure-cli
azure:
    require-sh sudo bash "https://aka.ms/InstallAzureCLIDeb"
    update --add az "sudo /usr/bin/az upgrade"
    az --version | head -n1

# https://www.google.com/chrome/
chrome:
    require-apt google-chrome-stable \
        --source google-chrome \
        --uri "https://dl.google.com/linux/chrome/deb/" \
        --key "https://dl.google.com/linux/linux_signing_key.pub"
    google-chrome --version

# https://www.anthropic.com/claude-code
claude: volta
    require-volta @anthropic-ai/claude-code
    claude --version

# https://direnv.net/
direnv:
    require-apt direnv
    direnv --version

# https://docs.docker.com/engine/install/ubuntu/
docker:
    require-apt docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
        --source docker \
        --uri "https://download.docker.com/linux/ubuntu" \
        --key "https://download.docker.com/linux/ubuntu/gpg" \
        --suite-codename \
        --component stable
    sudo usermod -aG docker "$(whoami)"
    docker --version

# https://github.com/google-gemini/gemini-cli
gemini: volta
    require-volta @google/gemini-cli
    gemini --version

# https://www.gimp.org/
gimp:
    require-apt gimp
    gimp --version

# https://git-scm.com/
git:
    require-apt git git-absorb
    [ -n "$EMAIL" ] && git config --global user.email "$EMAIL"
    [ -n "$NAME" ] && git config --global user.name "$NAME"
    git config --global core.autocrlf input
    git config --global init.defaultBranch main
    git config --global rebase.autosquash true
    git --version

# https://cli.github.com/
github: git
    require-apt gh \
        --source github-cli \
        --uri "https://cli.github.com/packages" \
        --key "https://cli.github.com/packages/githubcli-archive-keyring.gpg"
    gh --version

# https://nodejs.org/en
node: volta
    node --version

# https://volta.sh/
volta:
    require-sh bash -s -- --skip-setup https://get.volta.sh
    require-volta node
    update --add volta "$HOME/.volta/bin/volta-migrate"
    append ~/.env 'VOLTA_HOME="$HOME/.volta"'
    append ~/.path ".volta/bin"
    append ~/.bashrc 'eval "$(volta completions bash)"'
    "$HOME/.volta/bin/volta" --version

# https://rustup.rs/
rust:
    require-sh "https://sh.rustup.rs"
    update --add rustup "$HOME/.cargo/bin/rustup update"
    "$HOME/.cargo/bin/rustc" --version

# https://deb.sury.org/
php:
    require-apt php php-cli php-mbstring php-xml php-zip \
        --source ondrej-php \
        --uri "https://ppa.launchpadcontent.net/ondrej/php/ubuntu" \
        --key "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xB8DC7E53946656EFBCE4C1DD71DAEAAB4AD4CAB6" \
        --suite-codename
    php --version

# https://getcomposer.org/download/
composer: git php
    require-apt unzip
    require-sh php -- --install-dir="$HOME/.local/bin" --filename=composer "https://getcomposer.org/installer"
    update --add composer "$HOME/.local/bin/composer self-update"
    append ~/.bashrc 'eval "$(composer completion bash)"'
    append ~/.path ".config/composer/vendor/bin"
    composer --version

# https://symfony.com/download
symfony: composer git php
    require-apt curl tar
    require-sh bash -s -- --install-dir="$HOME/.local/bin" "https://get.symfony.com/cli/installer"
    append ~/.bashrc 'eval "$(symfony completion bash)"'
    symfony -V

# https://gnunn1.github.io/tilix-web/
tilix:
    require-apt tilix
    tilix --version

# https://docs.astral.sh/uv/
uv:
    require-sh https://astral.sh/uv/install.sh
    update --add uv "$HOME/.local/bin/uv self update"
    append ~/.bashrc 'eval "$(uv generate-shell-completion bash)"'
    append ~/.bashrc 'eval "$(uvx --generate-shell-completion bash)"'
    uv --version

# https://www.vim.org/
vim:
    require-apt vim
    sudo update-alternatives --set editor /usr/bin/vim.basic
    echo 'SELECTED_EDITOR="/usr/bin/vim.basic"' > ~/.selected_editor
    vim --version | head -n1

# https://code.visualstudio.com/
vscode:
    require-apt code \
        --source vscode \
        --uri "https://packages.microsoft.com/repos/code" \
        --key "https://packages.microsoft.com/keys/microsoft.asc"
    update --add code "code --update-extensions"
    code --version
