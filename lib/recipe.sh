# shellcheck shell=bash disable=SC2016

# https://github.com/Azure/azure-cli
recipe::azure() {
    remote::shell sudo bash "https://aka.ms/InstallAzureCLIDeb"
    update --add az "sudo /usr/bin/az upgrade"
    az --version | head -n1
}

# https://brave.com/linux/
recipe::brave() {
    apt::source brave-browser \
        --uri "https://brave-browser-apt-release.s3.brave.com" \
        --key "https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg"
    apt::install brave-browser
    brave-browser --version | head -n1
}

# https://www.google.com/chrome/
recipe::chrome() {
    apt::source google-chrome \
        --uri "https://dl.google.com/linux/chrome/deb/" \
        --key "https://dl.google.com/linux/linux_signing_key.pub"
    apt::install google-chrome-stable
    google-chrome --version | head -n1
}

# https://www.anthropic.com/claude-code
recipe::claude() {
    apt::install socat bubblewrap
    remote::shell bash "https://claude.ai/install.sh"
    update --add claude "${HOME}/.local/bin/claude update"
    "${HOME}/.local/bin/claude" --version | head -n1
}

# https://getcomposer.org/download/
# Dependencies: git, php
recipe::composer() {
    task::run recipe::git
    task::run recipe::php
    apt::install unzip
    remote::shell php -- --install-dir="${HOME}/.local/bin" --filename=composer "https://getcomposer.org/installer"
    update --add composer "${HOME}/.local/bin/composer self-update"
    config::add ~/.bash_completion 'eval "$(composer completion bash)"'
    config::add ~/.path ".config/composer/vendor/bin"
    composer --no-ansi --version | head -n1
}

# https://direnv.net/
recipe::direnv() {
    apt::install direnv
    direnv --version | head -n1
}

# https://docs.docker.com/engine/install/ubuntu/
recipe::docker() {
    apt::source docker \
        --uri "https://download.docker.com/linux/ubuntu" \
        --key "https://download.docker.com/linux/ubuntu/gpg" \
        --suite-codename \
        --component stable
    apt::install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo usermod -aG docker "$(whoami)"
    docker --version | head -n1
}

# https://github.com/google-gemini/gemini-cli
# Dependencies: node
recipe::gemini() {
    task::run recipe::node
    "${HOME}/.local/share/pnpm/pnpm" add --global @google/gemini-cli
    gemini --version | head -n1
}

# https://www.gimp.org/
recipe::gimp() {
    apt::install gimp
    gimp --version | head -n1
}

# https://git-scm.com/
recipe::git() {
    apt::install git git-absorb
    [[ -n "${EMAIL:-}" ]] && git config --global user.email "${EMAIL}"
    [[ -n "${NAME:-}" ]] && git config --global user.name "${NAME}"
    git config --global core.autocrlf input
    git config --global init.defaultBranch main
    git config --global rebase.autosquash true
    git --version | head -n1
}

# https://cli.github.com/
# Dependencies: git
recipe::github() {
    task::run recipe::git
    apt::source github-cli \
        --uri "https://cli.github.com/packages" \
        --key "https://cli.github.com/packages/githubcli-archive-keyring.gpg"
    apt::install gh
    config::add ~/.bash_completion 'eval "$(gh completion -s bash)"'
    gh --version | head -n1
}

# https://htop.dev/
recipe::htop() {
    apt::install htop
    htop --version | head -n1
}

# https://github.com/casey/just
recipe::just() {
    apt::install just
    just --version | head -n1
}

# https://nodejs.org/en
# Dependencies: pnpm
recipe::node() {
    task::run recipe::pnpm
    "${HOME}/.local/share/pnpm/pnpm" env use --global lts
    node --version | head -n1
}

# https://ollama.com/download/linux
recipe::ollama() {
    apt::install zstd
    remote::shell sh https://ollama.com/install.sh
    ollama --version | tail -n1
}

# https://opencode.ai/download
recipe::opencode() {
    remote::shell bash "https://opencode.ai/install"
    config::add ~/.path ".opencode/bin"
    update --add opencode "${HOME}/.opencode/bin/opencode update"
    "${HOME}/.opencode/bin/opencode" --version | head -n1
}

# https://deb.sury.org/
recipe::php() {
    apt::source ondrej-php \
        --uri "https://ppa.launchpadcontent.net/ondrej/php/ubuntu" \
        --key "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xB8DC7E53946656EFBCE4C1DD71DAEAAB4AD4CAB6" \
        --suite-codename
    apt::install php php-cli php-mbstring php-xml php-zip
    php --version | head -n1
}

# https://pnpm.io/
recipe::pnpm() {
    export PNPM_HOME="${HOME}/.local/share/pnpm"
    export PATH="${PNPM_HOME}:${PATH}"
    if [[ ! -f "${HOME}/.local/share/pnpm/pnpm" ]]; then
        cp -p "${HOME}/.bashrc" "${HOME}/.bashrc.bak"
        if remote::shell bash https://get.pnpm.io/install.sh; then
            rm "${HOME}/.bashrc.bak"
        else
            mv "${HOME}/.bashrc.bak" "${HOME}/.bashrc"
            return 1
        fi
    fi
    update --add pnpm "${HOME}/.local/share/pnpm/pnpm self-update"
    update --add pnpm-packages "${HOME}/.local/share/pnpm/pnpm update --global"
    config::add ~/.env 'PNPM_HOME="${HOME}/.local/share/pnpm"'
    config::add ~/.path ".local/share/pnpm"
    config::add ~/.bash_completion 'eval "$(~/.local/share/pnpm/pnpm completion bash)"'
    "${HOME}/.local/share/pnpm/pnpm" --version | head -n1
}

# https://rustup.rs/
recipe::rust() {
    remote::shell sh -s -- -y "https://sh.rustup.rs"
    update --add rustup "${HOME}/.cargo/bin/rustup update"
    config::add ~/.path ".cargo/bin"
    config::add ~/.bash_completion 'eval "$(rustup completions bash cargo)"'
    config::add ~/.bash_completion 'eval "$(rustup completions bash rustup)"'
    "${HOME}/.cargo/bin/rustc" --version | head -n1
}

# https://symfony.com/download
# Dependencies: composer, git
recipe::symfony() {
    task::run recipe::composer
    task::run recipe::git
    apt::install curl tar
    remote::shell bash -s -- --install-dir="${HOME}/.local/bin" "https://get.symfony.com/cli/installer"
    config::add ~/.bash_completion 'eval "$(symfony completion bash)"'
    symfony --no-ansi version | head -n1
}

# https://gnunn1.github.io/tilix-web/
recipe::tilix() {
    apt::install tilix
    dpkg -s tilix | grep ^Version | head -n1
}

# https://docs.astral.sh/uv/
recipe::uv() {
    remote::shell https://astral.sh/uv/install.sh
    update --add uv "${HOME}/.local/bin/uv self update && ${HOME}/.local/bin/uv tool upgrade --all"
    config::add ~/.bash_completion 'eval "$(uv generate-shell-completion bash)"'
    config::add ~/.bash_completion 'eval "$(uvx --generate-shell-completion bash)"'
    uv --version | head -n1
}

# https://www.vim.org/
recipe::vim() {
    apt::install vim
    sudo update-alternatives --set editor /usr/bin/vim.basic
    # Only write if file doesn't exist or has different content
    local editor_setting='SELECTED_EDITOR="/usr/bin/vim.basic"'
    if [[ ! -f ~/.selected_editor ]] || ! grep -Fxq "${editor_setting}" ~/.selected_editor; then
        echo "${editor_setting}" > ~/.selected_editor
    fi
    vim --version | head -n1
}

# https://code.visualstudio.com/
recipe::vscode() {
    apt::source vscode \
        --uri "https://packages.microsoft.com/repos/code" \
        --key "https://packages.microsoft.com/keys/microsoft.asc"
    apt::install code
    update --add code "code --update-extensions"
    code --version | head -n1
}
