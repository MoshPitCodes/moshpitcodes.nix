# Plan: Integrate mcp-td-sidecar MCP Server into NixOS Flake

## Task Description

Integrate the [mcp-td-sidecar](https://github.com/MoshPitLabs/mcp-td-sidecar) MCP server into the moshpitcodes.nix flake so that TD task management and Sidecar terminal dashboard tools are exposed to both Claude Code and OpenCode as MCP tools. The server is a TypeScript MCP server built with Bun that bridges the `td` CLI and `sidecar` TUI into AI assistant workflows.

## Objective

When this plan is complete:
- The mcp-td-sidecar flake is declared as an input in `flake.nix`
- The `td-sidecar-mcp-server` package is available via the flake
- Both Claude Code (`~/.claude/settings.json`) and OpenCode (`~/.config/opencode/config.json`) have the `td-sidecar` MCP server configured
- The Claude Code activation script registers `td-sidecar` via `claude mcp add`
- `td` and `sidecar` binaries are available on `PATH` at runtime (already handled by `sidecar.nix` module and overlays)
- The integration works on all hosts that import the development modules (desktop via `default.nix`, WSL via `default.wsl.nix`)

## Problem Statement

The `td` CLI and `sidecar` TUI are already installed as system packages (via overlays and `sidecar.nix` module), but AI assistants (Claude Code, OpenCode) cannot interact with them programmatically. The mcp-td-sidecar MCP server bridges this gap by exposing TD task management operations as MCP tools, but it is not yet wired into the Nix configuration.

## Solution Approach

Follow the established pattern used by `mcp-discord`:

1. **Flake input**: Add `mcp-td-sidecar` as a flake input with `inputs.nixpkgs.follows`
2. **Package reference**: Import `td-sidecar-mcp-server` from the flake's packages output in both `claude-code.nix` and `opencode.nix`
3. **MCP config**: Add `td-sidecar` entries to the `mcpServers` attrsets in both modules
4. **Activation script**: Register with Claude Code CLI in the existing activation script
5. **No new wrapper needed**: The flake-built binary includes its own Bun wrapper, unlike local MCP servers that need runtime directory checks

## Relevant Files

Use these files to complete the task:

- **`flake.nix`** - Add `mcp-td-sidecar` input (lines 60-63 show the `mcp-discord` pattern to follow)
- **`modules/home/development/claude-code.nix`** - Add MCP server to Claude Code config (lines 41-61 for package import + mcpServers, lines 196-231 for activation script)
- **`modules/home/development/opencode.nix`** - Add MCP server to OpenCode config (lines 59-97 for package import + mcpServers)
- **`modules/home/development/sidecar.nix`** - Reference only; confirms `td` and `sidecar` packages are already installed
- **`overlays/default.nix`** - Reference only; confirms `sidecar.nix` and `td.nix` overlays exist
- **`modules/home/development/default.nix`** - Reference only; desktop imports (includes sidecar)
- **`modules/home/development/default.wsl.nix`** - Reference only; WSL imports (excludes sidecar but includes claude-code + opencode)

### New Files

None. All changes are edits to existing files.

## Implementation Phases

### Phase 1: Foundation

Add the flake input so the package is available to the configuration.

### Phase 2: Core Implementation

Wire the MCP server into both Claude Code and OpenCode modules following the established `mcp-discord` pattern.

### Phase 3: Integration & Polish

Validate the configuration builds, verify MCP server registration, and ensure `td`/`sidecar` are available on PATH when the MCP server runs.

## Team Orchestration

- You operate as the team lead and orchestrate the team to execute the plan.
- You're responsible for deploying the right team members with the right context to execute the plan.
- IMPORTANT: You NEVER operate directly on the codebase. You use `Task` and `Task*` tools to deploy team members to to the building, validating, testing, deploying, and other tasks.
  - This is critical. You're job is to act as a high level director of the team, not a builder.
  - You're role is to validate all work is going well and make sure the team is on track to complete the plan.
  - You'll orchestrate this by using the Task* Tools to manage coordination between the team members.
  - Communication is paramount. You'll use the Task* Tools to communicate with the team members and ensure they're on track to complete the plan.
- Take note of the session id of each team member. This is how you'll reference them.

### Team Members

- Builder
  - Name: builder-nix-flake
  - Role: Add mcp-td-sidecar flake input to flake.nix
  - Agent Type: builder
  - Resume: true

- Builder
  - Name: builder-claude-code
  - Role: Wire td-sidecar MCP server into claude-code.nix (package import, mcpServers config, activation script registration)
  - Agent Type: builder
  - Resume: true

- Builder
  - Name: builder-opencode
  - Role: Wire td-sidecar MCP server into opencode.nix (package import, mcpServers config)
  - Agent Type: builder
  - Resume: true

- Validator
  - Name: validator-nix
  - Role: Read-only validation that all changes are syntactically correct, follow existing patterns, and the flake evaluates without errors
  - Agent Type: validator
  - Resume: false

## Step by Step Tasks

- IMPORTANT: Execute every step in order, top to bottom. Each task maps directly to a `TaskCreate` call.
- Before you start, run `TaskCreate` to create the initial task list that all team members can see and execute.

### 1. Add mcp-td-sidecar flake input
- **Task ID**: add-flake-input
- **Depends On**: none
- **Assigned To**: builder-nix-flake
- **Agent Type**: builder
- **Parallel**: false
- Edit `flake.nix` to add the `mcp-td-sidecar` input after the existing `mcp-discord` input (after line 63)
- The input should follow the exact same pattern as `mcp-discord`:
  ```nix
  mcp-td-sidecar = {
    url = "github:MoshPitLabs/mcp-td-sidecar";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  ```
- Do NOT remove or modify the existing `sidecar` and `td` non-flake inputs (lines 64-71) - those are used by the overlays for the standalone CLI tools

### 2. Wire td-sidecar into claude-code.nix
- **Task ID**: wire-claude-code
- **Depends On**: add-flake-input
- **Assigned To**: builder-claude-code
- **Agent Type**: builder
- **Parallel**: true (can run in parallel with wire-opencode)
- **Step A**: Add package import after the `discordMcpServer` line (after line 42):
  ```nix
  tdSidecarMcpServer =
    inputs.mcp-td-sidecar.packages.${pkgs.stdenv.hostPlatform.system}.td-sidecar-mcp-server;
  ```
- **Step B**: Add `td-sidecar` entry to the `mcpServers` attrset (after the `linear` entry, around line 61):
  ```nix
  td-sidecar = {
    type = "stdio";
    command = "${tdSidecarMcpServer}/bin/td-sidecar-mcp-server";
    args = [ ];
    env = { };
  };
  ```
- **Step C**: Add registration in the `home.activation.claudeCodeMcpServers` script (after the Linear registration, around line 228):
  ```bash
  # Register TD Sidecar MCP server
  add_mcp_server "td-sidecar" "${tdSidecarMcpServer}/bin/td-sidecar-mcp-server"
  ```
- The `globalSettings.mcpServers` (line 70) already references the `mcpServers` variable, so the settings.json will automatically include the new server

### 3. Wire td-sidecar into opencode.nix
- **Task ID**: wire-opencode
- **Depends On**: add-flake-input
- **Assigned To**: builder-opencode
- **Agent Type**: builder
- **Parallel**: true (can run in parallel with wire-claude-code)
- **Step A**: Add package import after the `discordMcpServer` line (after line 63):
  ```nix
  tdSidecarMcpServer =
    inputs.mcp-td-sidecar.packages.${pkgs.stdenv.hostPlatform.system}.td-sidecar-mcp-server;
  ```
- **Step B**: Add `td-sidecar` entry to the `mcpServers` attrset (after the `elastic-stack` entry, around line 96):
  ```nix
  td-sidecar = {
    type = "local";
    command = [ "${tdSidecarMcpServer}/bin/td-sidecar-mcp-server" ];
    enabled = true;
  };
  ```
- Note: OpenCode uses `type = "local"` and `command` as a list, while Claude Code uses `type = "stdio"` and `command` as a string. Follow the existing patterns in each file.

### 4. Validate all changes
- **Task ID**: validate-all
- **Depends On**: add-flake-input, wire-claude-code, wire-opencode
- **Assigned To**: validator-nix
- **Agent Type**: validator
- **Parallel**: false
- Read all three modified files and verify:
  - `flake.nix`: The `mcp-td-sidecar` input is correctly placed and follows the `mcp-discord` pattern
  - `claude-code.nix`: The package import, mcpServers entry, and activation script registration all use the correct Nix store path (`${tdSidecarMcpServer}/bin/td-sidecar-mcp-server`)
  - `opencode.nix`: The package import and mcpServers entry use the correct format (`type = "local"`, command as list)
- Verify no existing configuration was accidentally removed or modified
- Run `nix flake check --no-build` to verify the flake structure is valid (if available)
- Run `nix eval .#nixosConfigurations.wsl.config.system.build.toplevel --impure 2>&1 | head -20` to catch Nix evaluation errors early
- Confirm the `sidecar` and `td` standalone inputs (non-flake, used by overlays) are still intact
- Verify the td-sidecar server will have `td` and `sidecar` on PATH at runtime (they're installed as system packages via `sidecar.nix`)

## Acceptance Criteria

- [ ] `flake.nix` contains `mcp-td-sidecar` input pointing to `github:MoshPitLabs/mcp-td-sidecar` with `inputs.nixpkgs.follows = "nixpkgs"`
- [ ] `claude-code.nix` imports `td-sidecar-mcp-server` from the flake and adds it to `mcpServers` with `type = "stdio"`
- [ ] `claude-code.nix` activation script registers `td-sidecar` via `add_mcp_server`
- [ ] `opencode.nix` imports `td-sidecar-mcp-server` from the flake and adds it to `mcpServers` with `type = "local"` and command as a list
- [ ] Existing `mcp-discord`, `linear`, and `elastic-stack` server configs are unchanged
- [ ] Existing `sidecar` and `td` non-flake inputs in `flake.nix` are unchanged
- [ ] No new wrapper scripts needed (the flake-built binary is self-contained with Bun)
- [ ] The Nix flake evaluates without errors

## Validation Commands

Execute these commands to validate the task is complete:

- `nix flake check --no-build 2>&1 | tail -5` - Verify flake structure is valid
- `nix eval --impure --expr '(builtins.getFlake (toString ./.)).inputs.mcp-td-sidecar' 2>&1 | head -5` - Verify the input resolves
- `grep -n 'mcp-td-sidecar' flake.nix` - Confirm flake input exists
- `grep -n 'tdSidecarMcpServer' modules/home/development/claude-code.nix` - Confirm Claude Code integration
- `grep -n 'tdSidecarMcpServer' modules/home/development/opencode.nix` - Confirm OpenCode integration
- `grep -n 'td-sidecar' modules/home/development/claude-code.nix` - Confirm MCP server config and activation
- `grep -n 'td-sidecar' modules/home/development/opencode.nix` - Confirm MCP server config

## Notes

- The mcp-td-sidecar flake exports three packages: `td-sidecar-mcp-server` (the built server), `td-sidecar-mcp` (wrapper with `--version` support), and `generate-mcp-config` (config generator utility). We use `td-sidecar-mcp-server` directly since the Nix config handles all configuration.
- The mcp-td-sidecar flake also exports an overlay (`overlays.default`) that could be used instead of direct package import, but the direct import pattern matches how `mcp-discord` is currently integrated.
- WSL hosts import `default.wsl.nix` which does NOT include `sidecar.nix` (no TUI on WSL). However, `claude-code.nix` and `opencode.nix` ARE imported on WSL. The MCP server will still work on WSL for task management even without the sidecar TUI - the `td` CLI is installed via `sidecar.nix` on desktop only. Consider whether `td` should be installed independently on WSL if MCP td tools are needed there.
- The `td` and `sidecar` binaries need to be on `PATH` when the MCP server runs. They are installed as system packages via the `sidecar.nix` module on desktop hosts. On WSL, if `sidecar.nix` is not imported, `td` won't be available and the MCP server's td-related tools will fail gracefully.
