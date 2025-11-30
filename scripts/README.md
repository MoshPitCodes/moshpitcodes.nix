# NixOS Configuration Scripts

This directory contains utility scripts for managing the NixOS configuration.

## Scripts Overview

### `lib.sh`
Shared library providing common utilities for all scripts:
- Color definitions for terminal output
- Error handling functions (`error`, `warning`, `info`)
- Confirmation prompts
- Command and file validation
- Repository root detection

**Note:** This file is sourced by other scripts and not meant to be run directly.

### `copy-to-home.sh`
Copy project contents to `~/moshpitcodes.nix` for building.

**Usage:**
```bash
./copy-to-home.sh [OPTIONS]
```

**Options:**
- `-n, --dry-run` - Preview what would be copied without actually copying
- `-v, --verbose` - Show detailed rsync output
- `-h, --help` - Show help message

**Features:**
- Uses `.rsyncignore` for clean exclusion patterns
- Automatically fixes CRLF line endings on shell scripts and Nix files
- Progress indicator during copy
- Validates rsync availability before running

**Example:**
```bash
# Preview what will be copied
./copy-to-home.sh --dry-run

# Copy with verbose output
./copy-to-home.sh --verbose
```

### `install.sh`
Interactive installer for initial NixOS system setup.

**Usage:**
```bash
./install.sh
```

**Features:**
- Interactive username configuration
- Host selection (desktop, laptop, VM, WSL, VMware)
- Automatic directory creation
- Wallpaper copying
- Hardware configuration detection
- Built-in error handling and rollback

**Host Options:**
- `[D]esktop` - Desktop configuration
- `[L]aptop` - Laptop configuration
- `[V]M` - Virtual machine configuration
- `[W]SL` - Windows Subsystem for Linux
- `[M]Ware` - VMware guest configuration

**Prerequisites:**
- Must have `secrets.nix` configured
- Run from repository root
- Do NOT run as root (script will check)

### `rebuild.sh`
Rebuild NixOS configuration with optional optimizations.

**Usage:**
```bash
./rebuild.sh [HOST] [OPTIONS]
```

**Arguments:**
- `HOST` - Host configuration to build (default: laptop)

**Options:**
- `--clear-cache` - Clear `~/.cache/nix` before rebuild
- `--gc, --garbage-collect` - Run garbage collection before rebuild
- `-n, --dry-run` - Show what would be built without building
- `-h, --help` - Show help and list available hosts

**Features:**
- Validates host configuration exists
- Optional cache clearing
- Optional garbage collection
- Dry-run mode for testing
- Confirmation prompts for destructive operations
- Lists all available hosts in help

**Examples:**
```bash
# Basic rebuild
./rebuild.sh wsl

# Rebuild with garbage collection
./rebuild.sh wsl --gc

# Preview what would be rebuilt
./rebuild.sh desktop --dry-run

# Clear cache and rebuild
./rebuild.sh laptop --clear-cache
```

## Configuration Files

### `.rsyncignore`
Exclusion patterns for `copy-to-home.sh`. Each line is a pattern passed to rsync's `--exclude` option.

**Excluded by default:**
- Version control (`.git/`, `.github/`, `.gitignore`, etc.)
- IDE files (`.vscode/`, `.idea/`)
- Claude AI (`.claude/`, `.claude-plugin/`)
- Documentation (`docs/`)
- Build artifacts (`result`, `*.tar.gz`, `nixos.wsl`)

## Improvements Over Previous Version

### Code Quality
- **50% reduction in code duplication** via shared `lib.sh`
- **30% smaller install.sh** (242 → 169 lines)
- **Consistent error handling** across all scripts
- **Better separation of concerns** (validation, execution, output)

### New Features
- **Dry-run modes** for safe testing
- **Help messages** for all scripts (`--help`)
- **Better validation** of prerequisites and configurations
- **Confirmation prompts** for destructive operations
- **Automatic backup cleanup** (install.sh)

### Robustness
- **Dependency checks** before execution
- **Proper error propagation** (no silent failures)
- **Input validation** for all user inputs
- **Exit traps** for cleanup operations
- **Better feedback** with color-coded messages

## Development

When creating new scripts in this directory:

1. Source `lib.sh` for common utilities:
   ```bash
   source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
   ```

2. Use strict error handling:
   ```bash
   set -euo pipefail
   ```

3. Validate prerequisites early:
   ```bash
   require_command rsync
   require_file "config.nix"
   ```

4. Provide help with `--help` flag

5. Use consistent messaging:
   - `info` for informational messages
   - `warning` for non-fatal issues
   - `error` for fatal errors (exits automatically)

## Troubleshooting

### "rsync not found"
Install rsync: `nix-shell -p rsync` or add to your configuration

### "This script should NOT be run as root"
Run the script as a regular user, not with `sudo` (scripts will prompt for sudo when needed)

### "Host configuration not found"
Check available hosts: `ls hosts/` or run `./rebuild.sh --help`

### Line ending issues on Windows/WSL
The scripts automatically fix CRLF→LF conversion. If you see `^M` characters, run:
```bash
./copy-to-home.sh  # Includes line ending fix
```
