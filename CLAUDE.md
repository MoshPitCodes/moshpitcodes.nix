# Claude Code Configuration

This file provides context and instructions for Claude Code (AI assistant) working in this repository.

---

---

## Table of Contents

- [General Instructions (Project-Independent)](#general-instructions-project-independent)
  - [Documentation Conventions](#documentation-conventions)
  - [Task-Driven Development with TD](#task-driven-development-with-td)
  - [Git Workflow](#git-workflow)
  - [Coding Standards](#coding-standards)
- [Project-Specific Context](#project-specific-context)
  - [Project Overview](#project-overview)
  - [Technology Stack](#technology-stack)
  - [Project Structure](#project-structure)
  - [Key Conventions](#key-conventions)

---

# General Instructions (Project-Independent)

## Documentation Conventions

When Claude Code creates documentation, plans, or notes during work:

| Document Type | Location | Purpose | Naming Convention |
|---------------|----------|---------|-------------------|
| **Project Documentation** | `docs/` | Guides, references, and project documentation | `kebab-case.md` |
| **Investigation Notes** | `docs/investigations/` | Research, comparisons, and decision analysis | `kebab-case.md` or `YYYY-MM-DD-topic.md` |
| **Architecture Docs** | `docs/architecture/` | System design, ADRs, diagrams | `kebab-case.md` |

**Guidelines:**
- Prefer discussing findings directly in chat over creating persistent documents
- Only create documents for complex investigations that benefit from persistence
- Use kebab-case for all filenames (e.g., `notification-daemon-comparison.md`)
- Place investigation documents in `docs/investigations/` when needed

**Note:** The user may prefer verbal discussion over document creation. Always confirm before creating extensive documentation files.

---

## Task-Driven Development with TD

This project can optionally use **[TD (sidecar/td)](https://github.com/marcus/td)** for task-driven development.

### What is TD?

TD is a lightweight task management CLI that enforces focused, trackable work sessions:
- **One task at a time** - Focus on a single task during each work session
- **Automatic file tracking** - All code changes are linked to tasks
- **Change logging** - Every modification is logged with context
- **Review workflow** - Tasks transition through defined states (todo → in_progress → in_review → done)

### TD Commands (If Used)

**Available Actions**:
- `td status` - Get current task status
- `td whoami` - Get current session identity
- `td usage --new-session` - Get usage overview and open work
- `td create` - Create a new task
- `td start TASK-123` - Start working on a task
- `td focus TASK-123` - Focus on a specific task
- `td link file.nix` - Link files to current task
- `td log "message"` - Add log entry to current task
- `td review TASK-123` - Submit task for review

**Usage Examples**:

```bash
# Check usage at session start
td usage --new-session

# Check current task status
td status

# Start working on a task
td start TASK-123

# Link files to current task
td link modules/home/hyprland.nix

# Add log entry
td log "Updated Hyprland configuration"

# Submit for review
td review TASK-123
```

**Requirements**:
- TD CLI installed and in PATH
- Initialized TD project (`td init` in project root)

**Note:** This project doesn't currently use TD, but it's available if needed for task tracking.

### When to Use TD (If Enabled)

**Use TD when:**
- Working on specific features or bugs
- Need to track what changed and why
- Collaborating with team members

**TD is optional for:**
- Quick exploratory work
- Reading code without modifications
- Running tests or build commands

### Documentation

- **[TD CLI Repository](https://github.com/marcus/td)** - Official TD documentation

---

## Git Workflow

### Git Flow Management

Git operations (branching, commits, PRs, releases) are managed by the `git-flow-manager` agent.

**Branch Types:**
- `main` - Production-ready code (protected)
- `develop` - Integration branch (if using Git Flow)
- `feature/*` - New features (e.g., `feature/user-authentication`)
- `bugfix/*` - Bug fixes (e.g., `bugfix/login-error`)
- `hotfix/*` - Emergency production fixes (e.g., `hotfix/security-patch`)
- `release/*` - Release preparation (e.g., `release/v1.2.0`)

**Commit Message Format:**
```
<type>: <subject>

<body>

<footer>
```

**Types:**
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting, no logic change)
- `refactor:` - Code refactoring
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks
- `perf:` - Performance improvements

**Note:** Follow these conventions for all git operations in this repository.

---

## Coding Standards

### General Best Practices

1. **Code Quality**
   - Write clear, self-documenting code
   - Use meaningful variable and function names
   - Follow language-specific style guides
   - Handle errors and exceptions gracefully
   - Avoid code duplication (DRY principle)

2. **Documentation**
   - Document complex logic with comments
   - Maintain up-to-date README files
   - Write clear commit messages
   - Document API endpoints and interfaces

3. **Testing**
   - Write unit tests for new features
   - Maintain high test coverage (aim for 80%+)
   - Include integration tests for critical paths
   - Test edge cases and error conditions

4. **Version Control**
   - Commit frequently with clear messages
   - Keep commits atomic (one logical change per commit)
   - Review your own code before creating PR
   - Respond to review feedback promptly

---

# Project-Specific Context

## Project Overview

**Project Name:** `moshpitcodes.nix`
**Description:** Personal NixOS system configuration supporting desktops, laptops, VMs, VMware guests, and WSL2.

**Primary Purpose:**
Declarative, reproducible system configuration for all personal machines using NixOS with Hyprland (Wayland compositor), Home Manager for user-level configuration, and a modular architecture. Built on NixOS unstable.

**Key Features:**
- Multi-host support (desktop, laptop, VM, VMware guest, WSL2)
- Hyprland Wayland compositor with full rice (waybar, rofi, swaync)
- Modular NixOS + Home Manager configuration
- Custom development environment provisioning
- Secrets management via git-ignored `secrets.nix` with Doppler runtime integration
- Custom packages (MonoLisa font, reposync)
- CI/CD with GitHub Actions (flake checks, configuration builds, Cachix caching)

---

## Technology Stack

### Core Technologies

**Languages:**
- Nix (primary - system and package configuration)
- Bash (scripts, shell configuration)

**Frameworks & Libraries:**
- NixOS (system configuration)
- Home Manager (user-level configuration)
- Hyprland (Wayland compositor)
- Nix Flakes (dependency management and reproducibility)

### Development Tools

**Package Manager:** Nix Flakes
**Version Control:** Git + GitHub
**Issue Tracking:** Linear
**Formatting:** treefmt (nixfmt for Nix, shfmt for shell)
**CI/CD:** GitHub Actions + Cachix binary cache
**Dependency Updates:** Renovate + Dependabot

---

## Project Structure

```
moshpitcodes.nix/
├── hosts/                         # Host-specific configurations
│   ├── desktop/                   # Desktop (i7-13700K, RTX 4070Ti Super)
│   ├── laptop/                    # ASUS Zenbook 14X OLED
│   ├── vm/                        # QEMU/KVM virtual machine
│   ├── vmware-guest/              # VMware guest
│   └── wsl/                       # Windows Subsystem for Linux 2
├── modules/                       # Reusable NixOS/Home Manager modules
│   ├── core/                      # System-level (bootloader, network, security, etc.)
│   └── home/                      # User-level (git, zsh, hyprland, development, etc.)
├── overlays/                      # Nix package overlays
├── pkgs/                          # Custom packages (monolisa, reposync)
├── shells/                        # Nix development shells
├── scripts/                       # System management scripts
├── docs/                          # Project documentation
│   └── templates/                 # Document templates (AGENTS.md, README.md)
├── wallpapers/                    # Desktop wallpapers
├── .github/                       # GitHub config (workflows, rulesets, PR template)
├── flake.nix                      # Nix Flake entry point
├── flake.lock                     # Pinned input versions
├── secrets.nix                    # User secrets (git-ignored)
├── secrets.nix.example            # Secrets template
├── AGENTS.md                      # This file (AI assistant configuration)
├── SECRETS.md                     # Secrets management documentation
└── README.md                      # Project overview
```

**Key Files:**
- `flake.nix` - Entry point defining all inputs, host configurations, dev shells, and overlays
- `secrets.nix` - Git-ignored plaintext secrets (credentials, API keys, paths)
- `secrets.nix.example` - Template for creating `secrets.nix`
- `modules/core/default.nix` - Aggregates all system-level modules
- `modules/home/default.nix` - Aggregates all user-level modules
- `modules/home/development/` - Development environment configuration
- `treefmt.toml` - Code formatting (nixfmt + shfmt)

---

## Key Conventions

### Nix Module Patterns

- Each module is a single `.nix` file or a directory with `default.nix`
- Modules receive `customsecrets` via `specialArgs` for accessing credentials
- API keys use `or ""` fallback pattern: `customsecrets.apiKeys.anthropic or ""`
- Environment variables are conditionally set with `lib.optionalAttrs`
- Activation scripts handle runtime file operations (copying keys, writing credentials)

---

## Project-Specific Workflows

### Adding a New NixOS Module

1. Create the `.nix` file in the appropriate directory (`modules/core/` or `modules/home/`)
2. Import it in the parent `default.nix`
3. If it needs secrets, add `customsecrets` to the function arguments
4. Test with `nix build .#nixosConfigurations.<host>.config.system.build.toplevel`
5. Apply with `sudo nixos-rebuild switch --flake . --impure`

### Adding a New Host

1. Create a directory under `hosts/` with `default.nix` and `hardware-configuration.nix`
2. Add the configuration to `flake.nix` under `nixosConfigurations`
3. Pass `customsecrets` via `specialArgs`
4. Import the appropriate core and home modules

### Secrets Management

Secrets flow through the system as follows:
1. Define values in `secrets.nix` (use `secrets.nix.example` as template)
2. `flake.nix` imports and validates the secrets, passing them as `customsecrets`
3. Modules access secrets via `customsecrets.<path>` with `or ""` fallbacks
4. At runtime, Doppler can inject/override API keys via shell aliases

**Reference:** See `SECRETS.md` for complete secrets management documentation.

---

## Common Tasks

### Rebuilding the System

```bash
# Standard rebuild (replace 'laptop' with your host: desktop, laptop, vmware-guest, wsl)
sudo nixos-rebuild switch --flake .#laptop --impure

# With Doppler secrets
doppler run -- sudo nixos-rebuild switch --flake .#laptop

# Test build without switching
nix build .#nixosConfigurations.laptop.config.system.build.toplevel --impure
```

**Laptop Deployment**:
⚠️ **IMPORTANT**: Before deploying to the laptop:
1. Boot NixOS installer on the laptop
2. Generate the real hardware configuration:
   ```bash
   sudo nixos-generate-config --show-hardware-config > hosts/laptop/hardware-configuration.nix
   ```
3. Commit the updated `hardware-configuration.nix`
4. Deploy: `sudo nixos-rebuild switch --flake .#laptop --impure`

The placeholder `hardware-configuration.nix` uses dummy UUIDs and must be replaced with actual hardware detection.

### Formatting Code

```bash
nix develop -c treefmt
```

### Updating Flake Inputs

```bash
nix flake update
```

### Repository Backups

The system includes automated daily backups of `~/Development` to the NAS (enabled for desktop, laptop, and WSL hosts).

**Configuration:**
- **Backup Destination:** Configured in `secrets.nix` under `backup.nasBackupPath`
- **Schedule:** Daily at 2 AM (configurable via `services.backup-repos.schedule`)
- **Implementation:** `modules/home/backup-repos.nix`

**Management Aliases:**
```bash
# Manually trigger backup now
backup-repos-now

# Check backup service status
backup-repos-status

# View backup logs (last 50 lines)
backup-repos-logs

# Check timer schedule
backup-repos-timer
```

**Manual Commands:**
```bash
# Start backup immediately
systemctl --user start backup-repos.service

# Check timer status
systemctl --user list-timers backup-repos.timer

# View full logs
journalctl --user -u backup-repos.service -f

# Disable backups for current host
services.backup-repos.enable = false;  # In host configuration
```

**Features:**
- Incremental backups using rsync
- Automatic exclusion of build artifacts (node_modules, target, .direnv, result)
- Desktop notifications on success/failure
- Graceful handling of NAS unavailability
- Persistent timer (runs on next boot if missed)
- Randomized 10-minute delay to avoid system load spikes

**Logs Location:** `~/.local/state/backup-repos.log`

### Managing Issues

**Issue Tracker:** Linear
**Agent:** Use the `linearapp` agent for issue management

### Creating Pull Requests

**Required in PR Description:**
- Summary of changes
- Which hosts are affected
- Whether secrets.nix changes are needed

**PR Title Format:**
```
<type>: <subject>
```

**Examples:**
- `feat: add bluetooth module for laptop`
- `fix: correct samba mount credentials path`
- `chore: update flake inputs`

---

## Resources

### Internal Documentation
- `README.md` - Project overview with screenshots
- `SECRETS.md` - Secrets management guide
- `docs/installation.md` - Complete installation guide
- `docs/configuration.md` - Configuration reference (monitors, wallpapers, secrets)
- `docs/wsl.md` - WSL2 setup guide
- `docs/development-shells.md` - Nix development environments
- `docs/scripts.md` - System management scripts

### External Resources
- [NixOS Manual](https://nixos.org/manual/nixos/unstable/)
- [Home Manager Options](https://nix-community.github.io/home-manager/options.xhtml)
- [Hyprland Wiki](https://wiki.hyprland.org/)
- [Nix Flakes Reference](https://nixos.wiki/wiki/Flakes)

---

**Last Updated:** 2026-02-11
**Maintained By:** moshpitcodes
