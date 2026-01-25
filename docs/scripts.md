# Scripts Reference

This document covers the system management scripts in the `scripts/` directory.

## Overview

| Script | Purpose |
|--------|---------|
| `lib.sh` | Shared utilities library |
| `install.sh` | Interactive installer |
| `rebuild.sh` | System rebuild with options |
| `copy-to-home.sh` | Copy project to home directory |
| `test-samba-mount.sh` | Samba troubleshooting |

## lib.sh

Shared library providing common utilities for all scripts:
- Color definitions for terminal output
- Error handling functions (`error`, `warning`, `info`)
- Confirmation prompts
- Command and file validation
- Repository root detection

> **Note:** This file is sourced by other scripts and not meant to be run directly.

## install.sh

Interactive installer for initial NixOS system setup.

**Usage:**
```bash
./install.sh
```

**Features:**
- Interactive host selection (desktop, laptop, VM, WSL, VMware)
- Automatic directory creation and wallpaper copying
- SSH key management from secrets.nix
- Hardware configuration detection
- Built-in error handling and rollback

**Prerequisites:**
- Must have `secrets.nix` configured before running
- Do NOT run as root

See [Installation Guide](installation.md) for detailed walkthrough.

## rebuild.sh

Rebuild NixOS configuration with optional optimizations.

**Usage:**
```bash
./scripts/rebuild.sh [HOST] [OPTIONS]
```

**Arguments:**
- `HOST` - Host configuration to build (default: laptop)

**Options:**
- `--clear-cache` - Clear `~/.cache/nix` before rebuild
- `--gc, --garbage-collect` - Run garbage collection before rebuild
- `-n, --dry-run` - Show what would be built without building
- `-h, --help` - Show help and list available hosts

**Examples:**
```bash
# Basic rebuild
./scripts/rebuild.sh wsl

# Rebuild with garbage collection
./scripts/rebuild.sh wsl --gc

# Preview what would be rebuilt
./scripts/rebuild.sh desktop --dry-run

# Clear cache and rebuild
./scripts/rebuild.sh laptop --clear-cache
```

## copy-to-home.sh

Copy project contents to `~/moshpitcodes.nix` for building.

**Usage:**
```bash
./scripts/copy-to-home.sh [OPTIONS]
```

**Options:**
- `-n, --dry-run` - Preview what would be copied without actually copying
- `-v, --verbose` - Show detailed rsync output
- `-h, --help` - Show help message

**Features:**
- Uses `.rsyncignore` for clean exclusion patterns
- Automatically fixes CRLF line endings on shell scripts and Nix files
- Progress indicator during copy

**Example:**
```bash
# Preview what will be copied
./scripts/copy-to-home.sh --dry-run

# Copy with verbose output
./scripts/copy-to-home.sh --verbose
```

## test-samba-mount.sh

Test and troubleshoot Samba/CIFS network share mounting.

**Usage:**
```bash
./scripts/test-samba-mount.sh
```

**Features:**
- Tests Samba credentials configuration
- Validates network connectivity to shares
- Helps diagnose mounting issues

## Configuration Files

### .rsyncignore

Exclusion patterns for `copy-to-home.sh`. Each line is a pattern passed to rsync's `--exclude` option.

**Excluded by default:**
- Version control (`.git/`, `.github/`, `.gitignore`, etc.)
- IDE files (`.vscode/`, `.idea/`)
- Claude AI (`.claude/`, `.claude-plugin/`)
- Documentation (`docs/`)
- Build artifacts (`result`, `*.tar.gz`, `nixos.wsl`)

## User Scripts

User scripts located in `modules/home/scripts/scripts/` are available in your PATH:

### Archive Management
- **extract** - Extract `tar.gz` archives: `extract <archive_file>`
- **compress** - Compress files/folders into `tar.gz`: `compress <file_or_folder>`

### Hyprland Toggles
- **toggle_blur** - Toggle Hyprland blur effect
- **toggle_opacity** - Toggle window opacity (0.90 <-> 1.0)
- **toggle_waybar** - Toggle Waybar visibility
- **toggle_float** - Toggle floating window state

### Media & Entertainment
- **music** - Manage Audacious music player (start/stop)
- **lofi** - Launch lofi music streams
- **twitch** - Quick access to Twitch streams

### Utilities
- **maxfetch** - System fetch utility
- **runbg** - Run commands detached from terminal: `runbg <command> <args>`
- **show-keybinds** - Display Hyprland keybindings reference
- **ascii** - Display ASCII art

### Wallpaper Management
- **wall-change** - Change wallpaper manually
- **wallpaper-picker** - Interactive wallpaper picker
- **random-wallpaper** - Set a random wallpaper from collection

### Screen Capture
- **screenshot** - Take screenshots with various options
- **record** - Screen recording utility

### System Management
- **power-menu** - Quick power options menu
- **rofi-power-menu** - Rofi-based power menu
- **vm-start** - Start virtual machines
- **tmux-sessions** - Manage tmux sessions

## Development Guidelines

When creating new scripts:

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
Check available hosts: `ls hosts/` or run `./scripts/rebuild.sh --help`

### Line ending issues on Windows/WSL
The scripts automatically fix CRLF->LF conversion. If you see `^M` characters, run:
```bash
./scripts/copy-to-home.sh  # Includes line ending fix
```
