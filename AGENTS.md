# AGENTS.md - Repository Context

Anna's Ubuntu setup repository - shell scripts and recipes for dev environment installation/updates.

## Design

The [install.sh](install.sh) script is used to integrate this setup into a user's home directory. It also asks for your NAME and EMAIL which then are stored as environment variables.

### Home Directory Files

- ~/.env is created to store environment variables
- ~/.path is created to store $PATH entries
- ~/.bash_completion is created to store bash completion commands
- ~/.bashrc and ~/.profile are enhanced to source [env](env) which loads the .env, .path and .bash_completion files into the environment.

## Project Directory Structure

```text
.
├── bin  # Executable bash scripts
├── etc  # Configuration files
├── lib  # Shared bash libraries
└── log  # Test logs (gitignored)
```

### Binaries

- [bin/setup](bin/setup) - Recipe based installer
- [bin/update](bin/update) - Updater for installed recipes
- [bin/py](bin/py) - Python REPL bootstrap using uv and the rich library

### Libraries

- [lib/apt.sh](lib/apt.sh) - APT package manager utilities (install, source)
- [lib/standard.sh](lib/standard.sh) - Core utilities (raise, help, trace, debug, with, version)
- [lib/config.sh](lib/config.sh) - Config file editing utilities
- [lib/recipe.sh](lib/recipe.sh) - Tool installation recipes
- [lib/remote.sh](lib/remote.sh) - Remote shell script execution utilities for downloading and executing scripts from URLs
- [lib/task.sh](lib/task.sh) - Task dependency management (run, schedule, work, next, list)

### Scripts

- [check.sh](check.sh) - Run shellcheck + shfmt (always run before committing)
- [demo.sh](demo.sh) - Demo using interactive shell in a docker container
- [format.sh](format.sh) - Format code (always run before committing)
- [test.sh](test.sh) - Test all recipes in a docker container

Before committing, run `./check.sh`, `./format.sh` and `test.sh` to check for defects.

## Coding Guidelines

### Script Details

- **lib/ modules**: Not executable, use `# shellcheck shell=bash` header
- **bin/ scripts**: Executable, `#!/bin/bash` shebang, use `set -euo pipefail`, source libs as needed, follow main() pattern
- **Namespace functions**: `module::function` where `module` matches the filename (e.g., `standard::raise` in standard.sh)
- **Separate var declaration from assignment**: `local var; var="$(cmd)"` not `local var="$(cmd)"`
- **Import libraries using BASH_SOURCE[0]**: `source "$(dirname "$(dirname "$(realpath "${BASH_SOURCE[0]}")")")/lib/standard.sh"`

### Documentation

All functions must have documentation comments following this format:

```bash
# Brief description
#
# Usage: function_name <arg1> [arg2]
#
# Arguments:
#   arg1  Description
#   arg2  Optional description
#
# Returns: Description (if applicable)
```

## Security Notes

Recipes download/execute external scripts via HTTPS (no checksum verification)
