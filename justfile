# shellcheck shell=bash disable=SC2016 disable=SC1036 disable=SC1088

export PNPM_HOME := env("HOME") + "/.local/share/pnpm"
export PATH := PNPM_HOME + ":" + env("PATH")

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
claude:
    require-apt socat bubblewrap
    require-sh bash "https://claude.ai/install.sh"
    update --add claude "${HOME}/.local/bin/claude update"
    "${HOME}/.local/bin/claude" --version | head -n1

# https://opencode.ai/download
opencode:
    require-sh bash "https://opencode.ai/install"
    append ~/.path ".opencode/bin"
    update --add opencode "${HOME}/.opencode/bin/opencode update"
    "${HOME}/.opencode/bin/opencode" --version | head -n1

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
gemini: node
    "${HOME}/.local/share/pnpm/pnpm" add --global @google/gemini-cli
    "${HOME}/.local/share/pnpm/gemini" --version

# https://www.gimp.org/
gimp:
    require-apt gimp
    gimp --version

# https://git-scm.com/
git:
    #!/bin/bash
    require-apt git git-absorb
    [[ -n "${EMAIL}" ]] && git config --global user.email "${EMAIL}"
    [[ -n "${NAME}" ]] && git config --global user.name "${NAME}"
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
    append ~/.bash_completion 'eval "$(gh completion -s bash)"'
    gh --version | head -n1

# https://htop.dev/
htop:
    require-apt htop
    htop --version

# https://nodejs.org/en
node: pnpm
    "${HOME}/.local/share/pnpm/pnpm" env use --global lts
    node --version

# https://pnpm.io/
pnpm:
    if [ ! -f "${HOME}/.local/share/pnpm/pnpm" ]; then \
        cp -p "${HOME}/.bashrc" "${HOME}/.bashrc.bak"; \
        require-sh bash https://get.pnpm.io/install.sh; \
        mv "${HOME}/.bashrc.bak" "${HOME}/.bashrc"; \
    fi
    update --add pnpm "${HOME}/.local/share/pnpm/pnpm self-update"
    update --add pnpm-packages "${HOME}/.local/share/pnpm/pnpm update --global"
    append ~/.env 'PNPM_HOME="${HOME}/.local/share/pnpm"'
    append ~/.path ".local/share/pnpm"
    append ~/.bash_completion 'eval "$(~/.local/share/pnpm/pnpm completion bash)"'
    "${HOME}/.local/share/pnpm/pnpm" --version

# https://rustup.rs/
rust:
    require-sh sh -s -- -y "https://sh.rustup.rs"
    update --add rustup "${HOME}/.cargo/bin/rustup update"
    append ~/.path ".cargo/bin"
    append ~/.bash_completion 'eval "$(rustup completions bash cargo)"'
    append ~/.bash_completion 'eval "$(rustup completions bash rustup)"'
    "${HOME}/.cargo/bin/rustc" --version

# https://deb.sury.org/
php:
    require-apt php php-cli php-mbstring php-xml php-zip \
        --source ondrej-php \
        --uri "https://ppa.launchpadcontent.net/ondrej/php/ubuntu" \
        --key "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xB8DC7E53946656EFBCE4C1DD71DAEAAB4AD4CAB6" \
        --suite-codename
    php --version | head -n1

# https://getcomposer.org/download/
composer: git php
    require-apt unzip
    require-sh php -- --install-dir="${HOME}/.local/bin" --filename=composer "https://getcomposer.org/installer"
    update --add composer "${HOME}/.local/bin/composer self-update"
    append ~/.bash_completion 'eval "$(composer completion bash)"'
    append ~/.path ".config/composer/vendor/bin"
    composer --no-ansi --version | head -n1

# https://symfony.com/download
symfony: composer git
    require-apt curl tar
    require-sh bash -s -- --install-dir="${HOME}/.local/bin" "https://get.symfony.com/cli/installer"
    append ~/.bash_completion 'eval "$(symfony completion bash)"'
    symfony --no-ansi version

# https://gnunn1.github.io/tilix-web/
tilix:
    require-apt tilix
    dpkg -s tilix | grep ^Version

# https://docs.astral.sh/uv/
uv:
    require-sh https://astral.sh/uv/install.sh
    update --add uv "${HOME}/.local/bin/uv self update && ${HOME}/.local/bin/uv tool upgrade --all"
    append ~/.bash_completion 'eval "$(uv generate-shell-completion bash)"'
    append ~/.bash_completion 'eval "$(uvx --generate-shell-completion bash)"'
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
    code --version | head -n1
