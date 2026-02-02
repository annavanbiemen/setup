# AGENTS.md - Repository Context for AI Agents

This file provides essential context for AI agents working on this repository.

## Repository Purpose

Anna's local Ubuntu setup repository containing configurations and scripts for managing development environments. Provides a unified toolchain installation and update system using shell scripts and justfile recipes.

## Directory Structure

```text
.
├── bin/                    # Executable scripts (added to PATH)
│   ├── append              # Append lines to files
│   ├── py                  # Python REPL with rich colors
│   ├── require-apt         # Install APT packages (with optional custom sources)
│   ├── require-deb         # Install .deb from remote URL
│   ├── require-sh          # Download and execute remote shell script
│   ├── setup               # Install entire dev toolchain
│   └── update              # Update all installed tools
├── lib/                    # Shared bash libraries
│   └── standard.sh         # Standard utilities (error, raise, usage, etc.)
├── etc/                    # Configuration files
│   └── pythonrc            # Python REPL configuration
├── check.sh                # Run shellcheck and shfmt on all scripts
├── demo.sh                 # Demo script for Docker testing
├── format.sh               # Auto-format all shell scripts with shfmt
├── install.sh              # Repository installation script
├── test.sh                 # Integration tests (Docker-based)
├── justfile                # Recipe definitions for dev tools (brave, chrome, docker, etc.)
└── env                     # Load ~/.env and ~/.path files
```

## Key Architecture Patterns

### 1. Standard Library

The repository provides a standard library in [lib/standard.sh](lib/standard.sh) with core utilities:

```bash
# Import pattern used in bin/ scripts
source "$(dirname "$(dirname "$(realpath "${BASH_SOURCE[0]}")")")/lib/standard.sh"
```

**Note:** `BASH_SOURCE[0]` is used instead of `$0` to ensure the pattern works correctly even when scripts are sourced (not just executed). `$0` refers to how the script was invoked, while `BASH_SOURCE[0]` always refers to the current script file.

**Available functions:**

- `standard::error` - Output error messages to stderr
- `standard::raise` - Exit with non-zero code, optionally running a command
- `standard::trace` - Print stack trace with arguments
- `standard::debug` - Enable debug mode with stack traces on errors
- `standard::with` - Run command with shell option temporarily enabled
- `standard::help` - Display help information from function comments
- `standard::version` - Show git version information

### 2. Script Structure Pattern

All `bin/` scripts follow this structure:

```bash
#!/bin/bash

# Exit on errors
set -euo pipefail

# Import libraries
source "$(dirname "$(dirname "$(realpath "${BASH_SOURCE[0]}")")")/lib/standard.sh"

# [Script description]
#
# Usage: script-name <args>
#
# Arguments:
#   arg  Description
main() {
    # Validate arguments
    [[ "$#" -eq N ]] || standard::raise standard::usage

    # Implementation
    # ...
}

# Invoke main entrypoint
main "$@"
```

### 3. The require-* Scripts

Three core scripts for package/software installation:

- **require-apt** - Install APT packages (with optional custom sources, GPG keys)
- **require-deb** - Download and install .deb packages from URLs
- **require-sh** - Download and execute remote shell scripts

These scripts are self-contained and use standard.sh utilities for error handling.

### 4. Justfile Recipes

The [justfile](justfile) contains recipes for installing various development tools:

```bash
# Install brave browser
just brave

# Install chrome
just chrome

# Install docker
just docker
```

Each recipe typically uses one or more `require-*` scripts.

## Important Files

### Core Scripts

- **[bin/setup](bin/setup)** - Main entry point for installing dev toolchain (calls just recipes)
- **[bin/update](bin/update)** - Updates all installed tools
- **[install.sh](install.sh)** - Repository installation (sets up PATH, configures git, creates ~/.env)

### Libraries

- **[lib/standard.sh](lib/standard.sh)** - Standard utilities (`standard::error`, `standard::raise`, `standard::usage`, `standard::trace`, `standard::debug`, `standard::with`, `standard::version`)
- **[lib/task.sh](lib/task.sh)** - Task dependency management (`task::run`, `task::schedule`, `task::next`, `task::work`, `task::list`, `task::summary`)
- **[lib/recipe.sh](lib/recipe.sh)** - Installation recipes for development tools (used by justfile). Contains `recipe::*` functions for various tools like docker, brave, pnpm, node, etc. Note: The pnpm recipe backs up and restores `~/.bashrc` to prevent the installer from modifying it.

### Testing & Quality

- **[check.sh](check.sh)** - Runs shellcheck and shfmt (linting + formatting checks)
- **[format.sh](format.sh)** - Auto-formats all shell scripts
- **[test.sh](test.sh)** - Docker-based integration tests

## Coding Standards

### Shell Scripting

1. **Always use strict mode:** `set -euo pipefail`
2. **Source standard.sh** for all new scripts in `bin/` that need utility functions
3. **Follow the main() pattern** for executable scripts
4. **Use standard library functions:**
   - `raise usage` instead of manual usage + exit
   - `raise error "message"` instead of echo + exit
5. **Declare local variables:** Always use `local` in functions
6. **Separate declaration from assignment** when using command substitution:

   ```bash
   local var
   var="$(command)"  # Not: local var="$(command)"
   ```

7. **Quote variables:** Always quote variables unless you need word splitting

### File Organization

- Executables go in `bin/`
- Libraries go in `lib/`

### Documentation

- All functions must have documentation comments following this format:

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

## Testing Workflow

Before committing changes:

1. **Format:** `./format.sh` - Auto-format all scripts
2. **Check:** `./check.sh` - Run shellcheck and verify formatting
3. **Test:** `./test.sh` - Run Docker-based integration tests (if applicable)
4. **Manual test:** Test affected justfile recipes

## Common Operations

### Adding a new lib/ module

1. Create `lib/module.sh` with `# shellcheck shell=bash` header, the file should NOT be executable itself
2. Define functions with `module::function` pattern where module matches the module name
3. Add documentation comments for each function
4. Source in scripts: `source "$(dirname "$(dirname "$(realpath "${BASH_SOURCE[0]}")")")/lib/module.sh"`
5. Create function aliases if needed for convenience

### Adding a new bin/ script

1. Create a new bash script with the `#!/bin/bash` shebang
2. Source standard.sh and create function aliases as needed
3. Define `main()` function with documentation comments
4. Add `main "$@"` at the end
5. Make executable: `chmod +x bin/script`
6. Test with `./check.sh`

### Adding a New Justfile Recipe

1. Add recipe to [justfile](justfile)
2. Use `require-apt`, `require-deb`, or `require-sh` as needed
3. Test the recipe: `./test.sh recipe`
4. Document in comments if the installation is complex

## Dependencies

### Bootstrap Dependencies

- bash
- curl (installed by require-sh if needed)
- ca-certificates (installed by require-sh if needed)

### Development Dependencies

- shellcheck (for linting)
- shfmt (for formatting)
- docker (for integration tests)
- just (for running recipes)

## Environment Variables

The setup uses `~/.env` for user-specific configuration:

- `NAME` - User's full name (for git config)
- `EMAIL` - User's email (for git config)

These are loaded via the `env` script.

## Git Workflow

- Repository is designed to be cloned to a user-chosen location
- `install.sh` adds `bin/` to PATH via `~/.path`
- Scripts can be called from anywhere after installation

## Security Considerations

### External Script Execution

Several recipes in [lib/recipe.sh](lib/recipe.sh) download and execute scripts from external sources without cryptographic verification:

- `recipe::azurecli` - <https://aka.ms/InstallAzureCLIDeb>
- `recipe::opencode` - <https://opencode.ai/install>
- `recipe::pnpm` - <https://get.pnpm.io/install.sh>
- `recipe::rust` - <https://sh.rustup.rs>
- `recipe::uv` - <https://astral.sh/uv/install.sh>

**Security assumptions:**

- HTTPS enforced via `--proto '=https'` flag in curl commands
- Minimum TLS 1.2 required via `--tlsv1.2` flag
- DNS and network infrastructure are trusted
- No checksum or signature verification is performed

**Risks:**

- Compromised DNS or network could serve malicious content
- No protection against supply chain attacks on upstream installers

**Recommendations for maintainers:**

- Consider adding optional checksum verification for critical tools
- Pin installer script versions where possible
- Review upstream installer scripts before updating
- Use official distribution packages when available

## Notes for AI Agents

1. **Never break backward compatibility** - Scripts are used in production
2. **Always run check.sh** before completing a task
3. **Test changes** with relevant justfile recipes
4. **Source standard.sh when needed** - Use standard library functions for error handling and utilities
5. **Follow the existing code style** - Use `./format.sh` to auto-format
6. **Document all functions** - Follow the established documentation format
7. **Use library functions** - Don't duplicate functionality that exists in lib/
8. **Handle errors gracefully** - Use `raise error` for clear error messages
9. **Avoid circular dependencies** - Be careful when require-* scripts call each other
10. **Keep scripts focused** - Each script should do one thing well
