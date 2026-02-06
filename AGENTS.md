This file provides context and instructions for AI assistants working in this repository.

---

## Table of Contents

- [General Instructions (Project-Independent)](#general-instructions-project-independent)
  - [OpenCode File Locations](#opencode-file-locations)
  - [Git Workflow](#git-workflow)
  - [Coding Standards](#coding-standards)
  - [Available Components](#available-components)
- [Project-Specific Context](#project-specific-context)
  - [Project Overview](#project-overview)
  - [Technology Stack](#technology-stack)
  - [Project Structure](#project-structure)
  - [Key Conventions](#key-conventions)

---

# General Instructions (Project-Independent)

## OpenCode File Locations

When creating OpenCode components, always use the correct directory:

| Component Type | Location | Purpose | Naming Convention |
|----------------|----------|---------|-------------------|
| **Plans** | `.opencode/plans/` | Implementation plans and design documents | `kebab-case.md` |
| **Notes** | `.opencode/notes/` | Session notes, research, and observations | `YYYY-MM-DD-topic.md` |
| **Commands** | `.opencode/commands/` | Slash commands (workflows, processes) | `kebab-case.md` |
| **Agents** | `.opencode/agents/` | Specialized domain expertise agents | `kebab-case.md` |
| **Skills** | `.opencode/skills/` | Bundled resources with scripts | `kebab-case/` |
| **Documentation** | `.opencode/docs/` | Guides and reference documentation | `kebab-case.md` |

**Important:**
- Never create plans, notes, or commands outside their designated directories
- Use kebab-case for all filenames (e.g., `my-new-command.md`)
- Commands are invoked as `/filename` (without `.md` extension)
- Agent names should not include model identifiers in the filename

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

**Reference:** See `.opencode/agents/git-flow-manager.md` for complete conventions.

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

## Available Components

### Slash Commands

Slash commands provide structured workflows and processes. Invoke with `/command-name`.

| Command | Description |
|---------|-------------|
| `/contemplation` | Expert guide for contemplation and problem-solving |
| `/create-architecture` | Generate architecture documentation with diagrams |
| `/diagnosis` | Issue diagnosis and root cause analysis |
| `/refactor-code` | Code refactoring assistance |
| `/reflection` | Expert guide for reflection techniques |
| `/structured-thinking` | Reflection and problem-solving framework |
| `/ultrathink` | Deep analysis and complex problem solving |

### Specialized Agents

Agents provide domain-specific expertise. Reference the agent name when requesting specialized help.

| Agent | Use Case |
|-------|----------|
| agent-creation | Creating specialized agents |
| architecture-review | Review code for best practices and architectural consistency |
| code-review | Code review for quality, security, and maintainability |
| command-creation | Creating slash commands |
| database-specialist | Database schema design, query optimization, migrations |
| devops-infrastructure | DevOps, Kubernetes, Terraform, CI/CD |
| discord-golang | Discord bots with Go |
| error-detective | Log analysis and debugging |
| git-flow-manager | Git Flow workflows and branch management |
| golang-backend-api | Go backend APIs |
| golang-tui-bubbletea | Go TUI with Bubbletea |
| hytale-modding | Hytale server mods/plugins with Java/Kotlin |
| java-kotlin-backend | Java/Kotlin Spring backend |
| linearapp | Linear.app project management |
| markdown-formatter | Markdown formatting |
| mcp-server | MCP server integration |
| mlops-engineer | ML pipelines and MLOps |
| nextjs-fullstack | Next.js App Router full-stack |
| nixos | NixOS, Nix Flakes, Home Manager |
| prompt-engineering | LLM prompt optimization |
| react-typescript | React + TypeScript frontend |
| rpg-mmo-systems-designer | RPG/MMO game systems design |
| security-engineer | Security and compliance |
| sveltekit-frontend | Svelte 5 + SvelteKit frontend |
| sveltekit-fullstack | SvelteKit full-stack apps |
| testing-engineer | Test strategies and automation |
| typescript-backend | TypeScript backend APIs |

**Agent Categories:**
- **Frontend**: React, Next.js, Svelte
- **Backend**: Go, Java/Kotlin, TypeScript
- **DevOps**: Kubernetes, Terraform, CI/CD, NixOS
- **Quality**: Code review, architecture review, security, testing
- **Meta**: Agent creation, command creation, prompt engineering

### Skills

Skills bundle resources, scripts, and guides for specific tasks.

| Skill | Purpose |
|-------|---------|
| artifacts-builder | Build complex React/Tailwind HTML artifacts |
| document-skills | Document manipulation (docx, pdf, pptx, xlsx) |
| mcp-builder | Build Model Context Protocol servers |
| skill-creator | Create new OpenCode skills |
| theme-factory | Apply professional themes to artifacts (10 presets) |

**Usage:** Skills are loaded dynamically when needed for specific tasks.

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
- Custom development environment provisioning (Claude Code, OpenCode, MCP servers)
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
- `modules/home/development/opencode.nix` - OpenCode + MCP server configuration
- `modules/home/development/claude-code.nix` - Claude Code configuration
- `treefmt.toml` - Code formatting (nixfmt + shfmt)

---

## Key Conventions

### Nix Module Patterns

- Each module is a single `.nix` file or a directory with `default.nix`
- Modules receive `customsecrets` via `specialArgs` for accessing credentials
- API keys use `or ""` fallback pattern: `customsecrets.apiKeys.anthropic or ""`
- Environment variables are conditionally set with `lib.optionalAttrs`
- Activation scripts handle runtime file operations (copying keys, writing credentials)

### Agent Naming

**Format:** `domain-technology.md` or `role-specialization.md`

**Guidelines:**
- Use kebab-case (lowercase with hyphens)
- Avoid model names in filenames
- Be descriptive but concise
- Examples: `golang-backend-api.md`, `code-review.md`, `nixos.md`

### Agent Frontmatter Structure

```yaml
---
name: agent-name
description: Use this agent when [use case]. Specializes in [areas]. Examples - [example 1], [example 2]
type: subagent
model: anthropic/claude-opus-4-5
model_metadata:
  complexity: high
  reasoning_required: true
  code_generation: true
  cost_tier: premium
  description: "Brief explanation"
fallbacks:
  - openai/gpt-5.2
  - anthropic/claude-sonnet-4-5
tools:
  write: true
  edit: true
permission:
  bash:
    "*": ask
    "specific-command*": allow
---
```

**Required Fields:**
- `name` - Agent identifier (matches filename without `.md`)
- `description` - Clear use case with examples
- `type` - `primary` or `subagent`
- `model` - Primary AI model to use

**Recommended Fields:**
- `model_metadata` - Complexity, reasoning needs, cost tier
- `fallbacks` - Alternative models if primary unavailable
- `tools` - Which file operations are allowed
- `permission` - Granular bash command permissions

### Command Structure

```yaml
---
allowed-tools: Read, Write, Edit, Bash
argument-hint: [mode] | --option1 | --option2
description: Brief description of command purpose
---

Command content with workflow instructions...
```

### Skill Structure

```
skill-name/
├── SKILL.md              # Main skill file with YAML frontmatter
├── scripts/              # Executable scripts
├── reference/            # Reference documentation
├── assets/               # Static assets
└── LICENSE.txt           # License information
```

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
# Standard rebuild
sudo nixos-rebuild switch --flake . --impure

# With Doppler secrets
doppler run -- sudo nixos-rebuild switch --flake .

# Test build without switching
nix build .#nixosConfigurations.desktop.config.system.build.toplevel
```

### Formatting Code

```bash
nix develop -c treefmt
```

### Updating Flake Inputs

```bash
nix flake update
```

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

**Last Updated:** 2026-02-06
**Maintained By:** moshpitcodes
