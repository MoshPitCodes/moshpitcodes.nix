# OpenCode Configuration

This file provides context and instructions for AI assistants working in this repository.

---

---

## Table of Contents

- [General Instructions (Project-Independent)](#general-instructions-project-independent)
  - [OpenCode File Locations](#opencode-file-locations)
  - [Plugin System Infrastructure (Optional)](#plugin-system-infrastructure-optional)
  - [Custom Tools](#custom-tools)
  - [Task-Driven Development with TD](#task-driven-development-with-td)
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

## Plugin System Infrastructure (Optional)

**Note:** This section is optional. Include it if your project uses OpenCode native TypeScript plugins.

OpenCode supports native TypeScript plugins that execute at key moments during AI assistant sessions. Plugins enable custom automation, logging, notifications, validation, and workflow integration.

### Overview

Projects can use **OpenCode Native Plugins** (TypeScript) instead of legacy Python hooks. Plugins hook into OpenCode's event system to provide:

- **Security Controls** - Block dangerous operations, protect sensitive files
- **Comprehensive Logging** - JSONL-formatted event tracking
- **File Validation** - Validate agent, skill, and command file structure
- **Post-Session Monitoring** - Detect orphaned file changes
- **Session Analytics** - Track git context, tool usage, and session statistics
- **System Notifications** - Cross-platform desktop notifications

### Example Plugins

The template includes reference plugins in `.opencode/plugins/`:

| Plugin | Purpose | Event Hooks |
|--------|---------|-------------|
| `security.ts` | Blocks dangerous commands, protects `.env` and credential files | `tool.execute.before` |
| `logging.ts` | Comprehensive JSONL event logging for all operations | All events |
| `markdown-validator.ts` | Validates agent/skill/command frontmatter (warn-only mode) | `file.edited` |
| `post-stop-detector.ts` | Detects files created/modified after session ends | `session.idle` |
| `session-context.ts` | Tracks git context, tool usage, and session statistics | `session.created`, `session.idle`, `tool.execute.after`, `file.edited` |
| `notifications.ts` | Sends system notifications for session events | `session.idle`, `session.error` |
| `td-enforcer.ts` | Enforces task-driven development with TD CLI integration | `permission.ask`, `tool.execute.after`, `session.created`, `session.idle`, `session.error` |

### Setup

1. **Install dependencies:**
   ```bash
   cd .opencode
   bun install  # or: npm install
   ```

2. **Plugins auto-load** from `.opencode/plugins/` at startup - no configuration needed!

3. **Dependencies** are declared in `.opencode/package.json` and installed by OpenCode via `bun install`.

### Resources

- [Plugin README](.opencode/plugins/README.md) - Complete plugin documentation (if included in template)
- [OpenCode Plugin SDK](https://www.npmjs.com/package/@opencode-ai/plugin) - Official SDK documentation

---

## Custom Tools

OpenCode supports custom tools that extend the AI's capabilities with project-specific functionality. Tools are defined as TypeScript modules in `.opencode/tools/`.

### TD Task Tool (`td.ts`)

**Purpose**: Direct integration with the [TD](https://github.com/marcus/td) task-management CLI for task-driven development workflows.

**Location**: `.opencode/tools/td.ts`

**Available Actions**:
- `status` - Get current task status (JSON format)
- `whoami` - Get current session identity (JSON format)
- `usage` - Get usage overview and open work (use `newSession: true` for `--new-session`)
- `create` - Create a new task (supports `type`, `priority`, `labels`, `description`, `parent`, `minor` parameters)
- `start` - Start working on a task
- `focus` - Focus on a specific task
- `link` - Link files to a task
- `log` - Add log entry to current task
- `review` - Submit task for review
- `handoff` - Capture handoff context for next session (supports `done`, `remaining`, `decision`, `uncertain` parameters)

**Usage Examples**:

```typescript
// Check usage and open work at session start
TD(action: "usage", newSession: true)

// Check current task status
TD(action: "status")

// Start working on a task
TD(action: "start", task: "TASK-123")

// Link files to current task
TD(action: "link", task: "TASK-123", files: ["src/foo.ts", "src/bar.ts"])

// Add log entry
TD(action: "log", message: "Implemented feature X")

// Submit for review
TD(action: "review", task: "TASK-123")

// Handoff with full context (MANDATORY at session end)
TD(
  action: "handoff",
  task: "TASK-123",
  done: "Implemented authentication middleware with JWT validation",
  remaining: "Add refresh token logic, write unit tests",
  decision: "Using RS256 for token signing, storing keys in environment variables",
  uncertain: "Should we support multiple JWT issuers? Need product input on token expiry duration"
)
```

**Requirements**:
- TD CLI installed and in PATH
- Initialized TD project (`td init` in project root)

**Integration**: The `td-enforcer.ts` plugin automates much of the TD workflow, but this tool provides direct manual control when needed.

---

## Task-Driven Development with TD

This project uses **[TD (sidecar/td)](https://github.com/marcus/td)** for task-driven development. TD integrates tightly with OpenCode through the `td-enforcer.ts` plugin and custom `td.ts` tool.

### What is TD?

TD is a lightweight task management CLI that enforces focused, trackable work sessions. It ensures:
- **One task at a time** - Focus on a single task during each work session
- **Automatic file tracking** - All code changes are linked to tasks
- **Change logging** - Every modification is logged with context
- **Review workflow** - Tasks transition through defined states (todo → in_progress → in_review → done)

### Plugin Integration

The `td-enforcer.ts` plugin automatically:

1. **Gates file writes** - Prompts you to start a task before making changes
2. **Auto-tracks files** - Links edited files to the focused task
3. **Auto-logs changes** - Adds change entries to the task log
4. **Monitors reviews** - Notifies when tasks are ready for review
5. **Tracks sessions** - Associates OpenCode sessions with TD work sessions

### Typical Workflow

```typescript
// 1. Check usage and start a task (via TD Tool)
TD(action: "usage", newSession: true)
TD(action: "start", task: "TASK-123")

// 2. Work in OpenCode
// → Plugin auto-tracks all file changes to TASK-123

// 3. Submit for review (via TD Tool)
TD(action: "review", task: "TASK-123")

// 4. Handoff context when done (via TD Tool)
TD(
  action: "handoff",
  task: "TASK-123",
  done: "Completed work description",
  remaining: "Outstanding tasks",
  decision: "Key decisions made",
  uncertain: "Open questions"
)
```

### When to Use TD

**Always use TD when:**
- Writing or modifying code files
- Working on specific tasks or features
- Collaborating with team members
- Need to track what changed and why

**TD is optional for:**
- Quick exploratory work
- Reading code without modifications
- Running tests or build commands

### Quick Reference (TD Tool Actions)

| Action | Purpose | Example |
|--------|---------|---------|
| `status` | Check current focused task | `TD(action: "status")` |
| `create` | Create a new task | `TD(action: "create", task: "Task title", type: "bug", priority: "P1", labels: "bug,critical")` |
| `start` | Start working on a task | `TD(action: "start", task: "TASK-123")` |
| `focus` | Switch focus to different task | `TD(action: "focus", task: "TASK-456")` |
| `link` | Manually link files to task | `TD(action: "link", task: "TASK-123", files: ["file.ts"])` |
| `log` | Add log entry to current task | `TD(action: "log", message: "Implemented feature")` |
| `review` | Submit task for review | `TD(action: "review", task: "TASK-123")` |
| `handoff` | Capture handoff context | `TD(action: "handoff", task: "TASK-123", done: "...", ...)` |

### Best Practices

1. **Start tasks before coding** - Use `TD(action: "start", task: "TASK-123")` before making changes
2. **Review status regularly** - Use `TD(action: "status")` to check current task
3. **Meaningful log entries** - Let the plugin auto-log or add manual context with `TD(action: "log", message: "...")`
4. **Handoff at session end** - Always use `TD(action: "handoff", ...)` when finishing work
5. **One task per session** - Focus on a single task for better tracking

### Mandatory TD Instructions for Agents

**CRITICAL: All AI agents MUST follow these TD requirements:**

#### 1. **Before ANY File Modifications** (MANDATORY)

**Check TD status first using TD Tool:**
```typescript
TD(action: "status")
```

**Verify:**
- Active task exists (`focus` or `inProgress` not empty)
- Task is appropriate for planned changes

**If NO active task:**
- **STOP immediately**
- **DO NOT write/edit any files**
- **Ask user to start a task:**
  ```typescript
  TD(action: "start", task: "TASK-123")
  ```

**Example Check:**
```typescript
// Check status
TD(action: "status")

// Response shows:
{
  "focus": null,           // NO TASK ACTIVE
  "inProgress": [],
  "blocked": []
}
// → STOP and ask user to start task before proceeding
```

#### 2. **When Using Sub-Agents via Task Tool** (CRITICAL)

When you invoke other agents using the Task tool, sub-agents **do NOT inherit TD enforcement**. You MUST:

**Before invoking sub-agent:**
```typescript
// 1. Check TD status
TD(action: "status")

// 2. If no task, start one FIRST
TD(action: "start", task: "TASK-123")

// 3. Include TD reminder in sub-agent prompt
```

**Prompt Template for Sub-Agents:**
```
CRITICAL TD REQUIREMENT:
Before modifying ANY files, you MUST:
1. Run: TD(action: "status")
2. Verify active task exists (focus or inProgress not empty)
3. If no task: STOP and notify user to start task via TD Tool

Current TD Context: [paste TD status output here]

Do NOT proceed with file modifications without active TD task.
```

**After sub-agent completes:**
```typescript
// Link all modified files to task
TD(action: "link", task: "TASK-123", files: ["file1.ts", "file2.ts"])
```

#### 3. **At Session Start** (MANDATORY)

```typescript
TD(action: "usage", newSession: true)
```
Run this to see all open work and current task context before beginning any work.

#### 4. **Before Context Ends** (ALWAYS MANDATORY)

```typescript
TD(
  action: "handoff",
  task: "TASK-123",
  done: "what was completed",
  remaining: "what still needs to be done",
  decision: "key decisions made",
  uncertain: "areas of uncertainty or questions"
)
```

This handoff is **MANDATORY** at the end of every session. Capture:
   - `done` - Concrete accomplishments and completed work
   - `remaining` - Outstanding tasks and next steps
   - `decision` - Important architectural or implementation decisions
   - `uncertain` - Open questions, blockers, or areas needing clarification

**Example:**
```typescript
// Session start
TD(action: "usage", newSession: true)

// ... work on task ...

// Session end (MANDATORY)
TD(
  action: "handoff",
  task: "TASK-123",
  done: "Implemented authentication middleware with JWT validation",
  remaining: "Add refresh token logic, write unit tests",
  decision: "Using RS256 for token signing, storing keys in environment variables",
  uncertain: "Should we support multiple JWT issuers? Need product input on token expiry duration"
)
```

### Documentation

- **[TD Integration Guide](.opencode/docs/td-integration.md)** - Complete integration documentation
- **[TD CLI Repository](https://github.com/marcus/td)** - Official TD documentation
- **[TD Tool](.opencode/tools/td.ts)** - OpenCode tool implementation
- **[TD Enforcer Plugin](.opencode/plugins/td-enforcer.ts)** - Plugin source code

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

**Common Commands:**
- `/contemplation` - Expert guide for contemplation and problem-solving
- `/create-architecture` - Generate architecture documentation with diagrams
- `/diagnosis` - Issue diagnosis and root cause analysis
- `/refactor-code` - Code refactoring assistance
- `/reflection` - Expert guide for reflection techniques
- `/structured-thinking` - Reflection and problem-solving framework
- `/ultrathink` - Deep analysis and complex problem solving

**Reference:** See `.opencode/AGENTS_INDEX.md` for complete command list.

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

**Model Selection:**
- Agents use different AI models based on task complexity
- See `.opencode/docs/model-selection-guide.md` for rationale
- Haiku (fast), Sonnet (balanced), Opus (complex reasoning)

**Reference:** See `.opencode/AGENTS_INDEX.md` for complete agent catalog.

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

**Reference:** See `.opencode/AGENTS_INDEX.md` for complete skill list.

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
- Custom development environment provisioning (OpenCode, MCP servers)
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
│   ├── init.sh
│   └── validate.py
├── reference/            # Reference documentation
│   └── api-docs.md
├── assets/              # Static assets
│   └── template.json
└── LICENSE.txt          # License information
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

**Last Updated:** 2026-02-11
**Maintained By:** moshpitcodes
