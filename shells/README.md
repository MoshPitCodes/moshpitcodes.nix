# Development Shells

This directory contains Nix development shell configurations.

For full documentation, see [docs/development-shells.md](../docs/development-shells.md).

## Quick Reference

| Shell | Command | Purpose |
|-------|---------|---------|
| default | `nix develop` | General NixOS development |
| devshell | `nix develop .#devshell` | Extended development tools |
| claude-flow | `nix develop .#claude-flow` | AI agent orchestration |

## Adding New Shells

1. Create `shells/your-shell.nix`
2. Add to `flake.nix` in `devShells` section
3. Document in `docs/development-shells.md`
4. Test: `nix develop .#your-shell`
