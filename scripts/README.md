# System Scripts

This directory contains utility scripts for managing the NixOS configuration.

For full documentation, see [docs/scripts.md](../docs/scripts.md).

## Quick Reference

| Script | Purpose |
|--------|---------|
| `lib.sh` | Shared utilities (sourced by other scripts) |
| `install.sh` | Interactive NixOS installer |
| `rebuild.sh` | System rebuild with options |
| `copy-to-home.sh` | Copy project to home directory |
| `test-samba-mount.sh` | Samba troubleshooting |

## Common Usage

```bash
# Initial installation
./install.sh

# Rebuild system
./scripts/rebuild.sh laptop

# Rebuild with garbage collection
./scripts/rebuild.sh desktop --gc

# Preview changes (dry run)
./scripts/rebuild.sh wsl --dry-run
```

## Development

When creating new scripts, source `lib.sh` for common utilities:

```bash
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
set -euo pipefail
```
