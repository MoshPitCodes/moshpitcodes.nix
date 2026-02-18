# Plan: Migrate Remaining Features from Old Config

## Task Description
Migrate the remaining features identified as missing from the old NixOS configuration (`moshpitcodes.nix-main`) to the current configuration (`shifttab.nix`). This covers JetBrains Rider IDE setup, VSCode Remote-WSL configuration, Sidecar + TD task management integration, Discord CSS theming, and resolving the Everforest vs Osaka Jade theme inconsistency across all modules.

## Objective
A fully feature-complete configuration with:
- JetBrains Rider IDE with dotnet SDK and Unity debugging support
- VSCode Remote-WSL extension management for WSL hosts
- Sidecar + TD task management aliases and helper functions
- Discord CSS theming using Osaka Jade palette (replacing old gruvbox)
- Consistent Osaka Jade color scheme across ALL modules (replacing Everforest remnants)

## Problem Statement
The current configuration is missing several features from the old config:
1. **Rider IDE** (`rider.nix`) - Complex JetBrains Rider wrapper with dotnet SDK 7, mono, msbuild, and Unity plugin symlinks. Completely absent.
2. **VSCode Remote** (`vscode-remote.nix`) - Extension management for Windows VSCode via Remote-WSL. Missing from WSL config.
3. **Sidecar + TD** (`sidecar.nix`) - Task-driven development integration with zsh aliases (`tdi`, `tdc`, `tds`, etc.), tmux split helpers, and project management functions. Referenced in CLAUDE.md but not present.
4. **Discord CSS Theming** - Old config used DiscoCSS with gruvbox theme. New config has bare Discord with no customization.
5. **Theme Inconsistency** - 16 modules use Everforest colors while MEMORY.md documents Osaka Jade as the intended theme. Only `tmux.nix` and `media.nix` currently use Osaka Jade colors.

**Clarification on packages**: The exploration agent initially reported several packages as missing (`easyeffects`, `gimp`, `thunderbird`, `onefetch`, `dconf-editor`, `wine`). These are ALL already present in `packages.nix`. No package migration is needed.

## Solution Approach
Migrate each feature independently with dedicated builder agents per feature. Use a parallel validation subgroup to verify each feature builds correctly, and a documentation subgroup to update project docs. The theme consistency task is the largest, touching 16+ files to replace Everforest hex codes with Osaka Jade equivalents.

## Relevant Files

**Files to Create:**
- `modules/home/rider.nix` — JetBrains Rider IDE configuration (from old config, adapted)
- `modules/home/vscode-remote.nix` — VSCode Remote-WSL extension management
- `modules/home/sidecar.nix` — Sidecar + TD task management integration
- `modules/home/discord/osaka-jade.css` — Osaka Jade Discord CSS theme (replacing gruvbox.css)

**Files to Modify:**
- `modules/home/default.nix` — Add rider.nix and sidecar.nix imports
- `modules/home/default.wsl.nix` — Add vscode-remote.nix import
- `modules/home/discord/default.nix` — Add DiscoCSS + Osaka Jade theme
- `modules/home/hyprland/default.nix` — Replace Everforest colors with Osaka Jade
- `modules/home/waybar/default.nix` — Replace Everforest colors with Osaka Jade
- `modules/home/walker.nix` — Replace Everforest colors with Osaka Jade
- `modules/home/wlogout.nix` — Replace Everforest colors with Osaka Jade
- `modules/home/swaync.nix` — Replace Everforest colors with Osaka Jade
- `modules/home/swaylock.nix` — Replace Everforest colors with Osaka Jade
- `modules/home/hyprlock.nix` — Replace Everforest colors with Osaka Jade
- `modules/home/ghostty.nix` — Switch from Everforest theme to custom Osaka Jade colors
- `modules/home/fzf.nix` — Replace Everforest colors with Osaka Jade
- `modules/home/lazygit.nix` — Replace Everforest colors with Osaka Jade
- `modules/home/cava.nix` — Replace Everforest colors with Osaka Jade
- `modules/home/btop.nix` — Replace Everforest colors with Osaka Jade
- `modules/home/vivid.nix` — Replace Everforest colors with Osaka Jade
- `modules/home/micro.nix` — Replace Everforest colors with Osaka Jade
- `modules/home/swayosd.nix` — Replace Everforest colors with Osaka Jade
- `modules/home/theming.nix` — Replace Everforest colors with Osaka Jade (GTK, Qt, fonts)
- `modules/home/starship.toml` — Replace Everforest colors with Osaka Jade
- `modules/home/nvim.nix` — Replace Everforest theme with Osaka Jade equivalent

**Reference Files (old config):**
- `/home/moshpitcodes/Development/moshpitcodes.nix-main/modules/home/rider.nix`
- `/home/moshpitcodes/Development/moshpitcodes.nix-main/modules/home/vscode-remote.nix`
- `/home/moshpitcodes/Development/moshpitcodes.nix-main/modules/home/development/sidecar.nix`
- `/home/moshpitcodes/Development/moshpitcodes.nix-main/modules/home/discord/discord.nix`
- `/home/moshpitcodes/Development/moshpitcodes.nix-main/modules/home/discord/gruvbox.css`

## Implementation Phases

### Phase 1: Foundation — Independent Feature Modules
Create the new standalone modules (rider.nix, vscode-remote.nix, sidecar.nix) that don't affect existing configuration. These can be built and tested independently without risk to the current system.

### Phase 2: Core Implementation — Theme Consistency + Discord
This is the highest-impact phase. Replace Everforest colors with Osaka Jade across all 16+ modules, and add Discord CSS theming. This phase requires careful coordination because it touches many files.

### Phase 3: Integration & Polish
Wire everything together (add imports to default.nix files), run full build validation, and update project documentation to reflect the new features and consistent theme.

## Color Mapping Reference

All Everforest → Osaka Jade color replacements follow this mapping:

| Component | Everforest | Osaka Jade | Notes |
|-----------|-----------|------------|-------|
| UI Background | `#232A2E` / `#2d353b` | `#11221C` | Primary background |
| UI Foreground | `#D3C6AA` | `#e6d8ba` | Primary text |
| Terminal Background | `#2d353b` | `#111c18` | Terminal/code bg |
| Terminal Foreground | `#D3C6AA` | `#C1C497` | Terminal/code text |
| Accent / Active | `#A7C080` (green) | `#71CEAD` (jade) | Primary accent |
| Border Active | `#D3C6AAff` | `#71CEADff` | Hyprland active border |
| Border Inactive | `#3D484Dff` | `#214237ff` | Hyprland inactive border |
| Surface / Selection | `#3D484D` | `#23372B` | Surface/hover |
| Red | `#E67E80` | `#FF5345` | Error/fail |
| Green | `#83C092` | `#549e6a` | Success/check |
| Yellow | `#DBBC7F` | `#E5C736` | Warning |
| Cyan | `#7FBBB3` | `#2DD5B7` | Info/highlight |
| Magenta | `#D699B6` | `#D2689C` | Special |

## Team Orchestration

- You operate as the team lead and orchestrate the team to execute the plan.
- You're responsible for deploying the right team members with the right context to execute the plan.
- IMPORTANT: You NEVER operate directly on the codebase. You use `Task` and `Task*` tools to deploy team members to to the building, validating, testing, deploying, and other tasks.

### Team Members

#### Implementation Subgroup (Builders)

- Builder
  - Name: builder-rider
  - Role: Create rider.nix module with JetBrains Rider IDE, dotnet SDK, and Unity debugging support
  - Agent Type: general-purpose
  - Resume: true

- Builder
  - Name: builder-wsl
  - Role: Create vscode-remote.nix module for WSL hosts with extension management
  - Agent Type: general-purpose
  - Resume: true

- Builder
  - Name: builder-sidecar
  - Role: Create sidecar.nix module with TD task management aliases and helper functions
  - Agent Type: general-purpose
  - Resume: true

- Builder
  - Name: builder-discord
  - Role: Add DiscoCSS to Discord module and create Osaka Jade CSS theme
  - Agent Type: general-purpose
  - Resume: true

- Builder
  - Name: builder-theme
  - Role: Replace Everforest colors with Osaka Jade across all 16+ configuration modules
  - Agent Type: general-purpose
  - Resume: true

#### Validation Subgroup (Validators)

- Builder
  - Name: validator-features
  - Role: Validate each new feature module builds correctly (rider, vscode-remote, sidecar, discord)
  - Agent Type: general-purpose
  - Resume: false

- Builder
  - Name: validator-theme
  - Role: Validate theme consistency — verify all modules use Osaka Jade colors and no Everforest remnants
  - Agent Type: general-purpose
  - Resume: false

- Builder
  - Name: validator-final
  - Role: Run final full system build validation after all changes are integrated
  - Agent Type: general-purpose
  - Resume: false

#### Documentation Subgroup (Documenters)

- Builder
  - Name: documenter-features
  - Role: Update project documentation with new features (rider, sidecar, vscode-remote, discord theming)
  - Agent Type: general-purpose
  - Resume: false

### TD Task Integration

**IMPORTANT**: Team members (builder, validator) use TD MCP tools to track their work. When executing the plan:

1. **Builders must** create TD tasks for their work:
   ```json
   mcp__td-sidecar__td_create_issue({
     "title": "Task title from plan",
     "type": "task",
     "priority": "P1",
     "description": "Detailed description with acceptance criteria"
   })
   ```

2. **Track progress** using:
   ```json
   mcp__td-sidecar__td_log_entry({"message": "Progress update"})
   ```

3. **Submit for review** when complete:
   ```json
   mcp__td-sidecar__td_submit_review({"task": "<task-id>"})
   ```

4. **Validators approve** validated work:
   ```json
   mcp__td-sidecar__td_approve_task({"task": "<task-id>"})
   ```

This ensures full traceability from planning → implementation → validation.

## Step by Step Tasks

- IMPORTANT: Execute every step in order, top to bottom. Each task maps directly to a `TaskCreate` call.
- Before you start, run `TaskCreate` to create the initial task list that all team members can see and execute.

### 1. Create Rider IDE Module
- **Task ID**: create-rider
- **Depends On**: none
- **Assigned To**: builder-rider
- **Agent Type**: general-purpose
- **Parallel**: true (can run alongside other Phase 1 tasks)
- Read old config at `/home/moshpitcodes/Development/moshpitcodes.nix-main/modules/home/rider.nix`
- Create `modules/home/rider.nix` based on old config with these adaptations:
  - Keep dotnet SDK 7, mono, msbuild, and Nuget
  - Keep the Rider wrapper with PATH and LD_LIBRARY_PATH injection
  - Keep Unity plugin symlink logic
  - Keep the `.desktop` file generation for Unity integration
  - Update any deprecated xorg package references if needed (xorg.libX11 → libx11, etc.)
- Add `./rider.nix` import to `modules/home/default.nix` under "Desktop applications" section

### 2. Create VSCode Remote-WSL Module
- **Task ID**: create-vscode-remote
- **Depends On**: none
- **Assigned To**: builder-wsl
- **Agent Type**: general-purpose
- **Parallel**: true
- Read old config at `/home/moshpitcodes/Development/moshpitcodes.nix-main/modules/home/vscode-remote.nix`
- Create `modules/home/vscode-remote.nix` based on old config with these adaptations:
  - Keep the extension ID list (update if needed — add newer extensions, remove obsolete ones)
  - Keep the `vscode-install-extensions` helper script
  - Keep the `wsl-settings.json` generation
  - Keep the README generation
  - Update formatter path from `nixpkgs-fmt` to `nixfmt` (matching current config)
  - Update any deprecated package references
- Add `./vscode-remote.nix` import to `modules/home/default.wsl.nix`

### 3. Create Sidecar + TD Module
- **Task ID**: create-sidecar
- **Depends On**: none
- **Assigned To**: builder-sidecar
- **Agent Type**: general-purpose
- **Parallel**: true
- Read old config at `/home/moshpitcodes/Development/moshpitcodes.nix-main/modules/home/development/sidecar.nix`
- Create `modules/home/sidecar.nix` based on old config with these adaptations:
  - Install `pkgs.sidecar` and `pkgs.td` packages
  - Keep the default sidecar config.json generation
  - Keep ALL zsh aliases: `sc`, `scd`, `scp`, `sidecar-help`, `sidecar-config`, `sidecar-edit`, `sidecar-add-project`
  - Keep ALL TD aliases: `tdi`, `tdc`, `tds`, `tdl`, `tdn`, `tdu`, `tdm`, `tdr`, `tda`, `tdh`, `tdq`, `tdb`
  - Keep ALL zsh functions: `sidecar-split`, `sidecar-dashboard`, `sidecar-goto`, `sidecar-td`, `td-init-project`, `td-ai-handoff`, `td-quick-start`, `td-stats`, `sidecar-tips`
  - Update project path from `~/Development/moshpitcodes.nix` to `~/Development/shifttab.nix`
  - Use full nix store paths for all executables (`${pkgs.jq}/bin/jq`, `${pkgs.fzf}/bin/fzf`)
- Add `./sidecar.nix` import to `modules/home/default.nix` under "Shell & CLI tools" section

### 4. Add Discord CSS Theming
- **Task ID**: add-discord-theme
- **Depends On**: none
- **Assigned To**: builder-discord
- **Agent Type**: general-purpose
- **Parallel**: true
- Read old discord config at `/home/moshpitcodes/Development/moshpitcodes.nix-main/modules/home/discord/discord.nix`
- Read old gruvbox CSS at `/home/moshpitcodes/Development/moshpitcodes.nix-main/modules/home/discord/gruvbox.css`
- Create `modules/home/discord/osaka-jade.css` — new Osaka Jade theme based on gruvbox.css structure:
  - Replace gruvbox colors with Osaka Jade palette:
    - `--background-primary: #11221C` (was `#1d2021`)
    - `--background-secondary: #0d1a15` (darker variant)
    - `--background-tertiary: #11221C`
    - `--text-normal: #e6d8ba` (was `#ebdbb2`)
    - `--interactive-normal: #e6d8ba`
    - `--channels-default: #71CEAD` (jade accent, was `#83a598`)
    - `--channeltextarea-background: #23372B` (surface, was `#32302f`)
  - Update syntax highlighting colors to match Osaka Jade palette
- Modify `modules/home/discord/default.nix`:
  - Add `pkgs.discocss` to packages
  - Add DiscoCSS config.json via `xdg.configFile`
  - Source `osaka-jade.css` as theme file

### 5. Migrate Theme: Osaka Jade Across All Modules
- **Task ID**: migrate-theme
- **Depends On**: none
- **Assigned To**: builder-theme
- **Agent Type**: general-purpose
- **Parallel**: true
- This is the largest task — update ALL 16+ modules from Everforest to Osaka Jade using the Color Mapping Reference table above
- **Critical files to update** (in priority order):
  1. `modules/home/theming.nix` — GTK theme, fonts, cursor, Qt theme, CSS color overrides
  2. `modules/home/hyprland/default.nix` — Active/inactive borders, background colors
  3. `modules/home/waybar/default.nix` — All status bar colors
  4. `modules/home/walker.nix` — Launcher colors
  5. `modules/home/ghostty.nix` — Replace `theme = Everforest Dark Hard` with explicit Osaka Jade colors using `palette` entries
  6. `modules/home/swaync.nix` — Notification center colors
  7. `modules/home/wlogout.nix` — Power menu colors
  8. `modules/home/swaylock.nix` — Lock screen colors
  9. `modules/home/hyprlock.nix` — Lock screen colors (disabled but keep consistent)
  10. `modules/home/fzf.nix` — Fuzzy finder colors
  11. `modules/home/lazygit.nix` — Git TUI colors
  12. `modules/home/cava.nix` — Audio visualizer colors
  13. `modules/home/btop.nix` — System monitor colors
  14. `modules/home/vivid.nix` — LS_COLORS theme
  15. `modules/home/micro.nix` — Micro editor colors
  16. `modules/home/swayosd.nix` — OSD overlay colors
  17. `modules/home/starship.toml` — Shell prompt colors
  18. `modules/home/nvim.nix` — Neovim colorscheme
- **Strategy**: For each file, search for Everforest hex codes and replace with Osaka Jade equivalents per the mapping table
- **Ghostty special handling**: Replace `theme = Everforest Dark Hard` with explicit palette configuration matching MEMORY.md Osaka Jade colors
- **Nvim special handling**: Change colorscheme from everforest to an osaka-jade compatible theme (check nvf theme options)
- Update file-level comments from "Everforest" to "Osaka Jade" where they appear

### 6. Validate Feature Modules
- **Task ID**: validate-features
- **Depends On**: create-rider, create-vscode-remote, create-sidecar, add-discord-theme
- **Assigned To**: validator-features
- **Agent Type**: general-purpose
- **Parallel**: false
- Run `nix build .#nixosConfigurations.vmware-guest.config.system.build.toplevel`
- Verify rider.nix imports correctly and JetBrains Rider package builds
- Verify sidecar.nix imports correctly and sidecar/td packages are in closure
- Verify discord default.nix has discocss and theme CSS
- Check for any package name conflicts or deprecated packages (especially xorg.* references)
- Note: vscode-remote.nix is WSL-only, may not be in vmware-guest build — verify it exists in the file tree

### 7. Validate Theme Consistency
- **Task ID**: validate-theme
- **Depends On**: migrate-theme
- **Assigned To**: validator-theme
- **Agent Type**: general-purpose
- **Parallel**: false (can run in parallel with validate-features)
- Grep ALL modules for residual Everforest hex codes: `D3C6AA`, `2d353b`, `232A2E`, `3D484D`, `A7C080`, `83C092`, `E67E80`, `DBBC7F`, `7FBBB3`, `D699B6`
- Only `tmux.nix` and `media.nix` should already have Osaka Jade — verify they're unchanged
- Verify Ghostty no longer uses `theme = Everforest Dark Hard`
- Verify Hyprland border colors are Osaka Jade
- Verify waybar, walker, swaync all use Osaka Jade palette
- Run `nix build .#nixosConfigurations.vmware-guest.config.system.build.toplevel` to ensure all color changes are syntactically valid

### 8. Final Full System Validation
- **Task ID**: validate-final
- **Depends On**: validate-features, validate-theme
- **Assigned To**: validator-final
- **Agent Type**: general-purpose
- **Parallel**: false
- Run `nix build .#nixosConfigurations.vmware-guest.config.system.build.toplevel` — must succeed with zero errors
- Verify NO Everforest hex codes remain in any module (except documentation/comments)
- Verify all new modules are imported in the correct default.nix files
- Verify `nix flake check` passes (warnings OK, no errors)
- List all packages added to the closure by the new modules

### 9. Update Project Documentation
- **Task ID**: update-docs
- **Depends On**: validate-final
- **Assigned To**: documenter-features
- **Agent Type**: general-purpose
- **Parallel**: false
- Update `docs/language-servers.md` to replace `nixfmt-rfc-style` references with `nixfmt`
- Create or update a migration tracking document listing:
  - What was migrated from the old config
  - What was intentionally NOT migrated (with rationale)
  - Current theme: Osaka Jade (not Everforest)
  - New features added (rider, sidecar, discord theming)
- Verify MEMORY.md theme documentation is consistent with actual implementation

## Acceptance Criteria
- [ ] `modules/home/rider.nix` exists with JetBrains Rider, dotnet SDK 7, mono, msbuild, and Unity symlinks
- [ ] `modules/home/vscode-remote.nix` exists with extension management and WSL settings
- [ ] `modules/home/sidecar.nix` exists with sidecar config, TD aliases, and zsh helper functions
- [ ] `modules/home/discord/osaka-jade.css` exists with Osaka Jade Discord theme
- [ ] `modules/home/discord/default.nix` installs discocss and applies osaka-jade theme
- [ ] ALL 16+ modules use Osaka Jade colors (no Everforest hex codes remain)
- [ ] Ghostty uses explicit Osaka Jade palette (not `theme = Everforest Dark Hard`)
- [ ] Hyprland borders use `#71CEADff` (active) and `#214237ff` (inactive)
- [ ] `modules/home/default.nix` imports rider.nix and sidecar.nix
- [ ] `modules/home/default.wsl.nix` imports vscode-remote.nix
- [ ] `nix build .#nixosConfigurations.vmware-guest.config.system.build.toplevel` succeeds
- [ ] `nix flake check` passes without errors
- [ ] Project documentation updated to reflect Osaka Jade theme and new features

## Validation Commands
Execute these commands to validate the task is complete:

- `nix build .#nixosConfigurations.vmware-guest.config.system.build.toplevel` — Full system build must succeed
- `grep -r "D3C6AA\|2d353b\|232A2E\|3D484D\|A7C080" modules/home/ --include="*.nix" --include="*.toml" -l` — Should return ZERO files (no Everforest remnants)
- `grep -r "11221C\|71CEAD\|214237\|e6d8ba" modules/home/ --include="*.nix" -l` — Should return MANY files (Osaka Jade everywhere)
- `grep -r "rider" modules/home/default.nix` — Verify rider.nix is imported
- `grep -r "sidecar" modules/home/default.nix` — Verify sidecar.nix is imported
- `grep -r "vscode-remote" modules/home/default.wsl.nix` — Verify vscode-remote.nix is imported
- `grep -r "discocss" modules/home/discord/default.nix` — Verify DiscoCSS is configured
- `grep -r "Everforest" modules/home/ --include="*.nix" -l` — Should only appear in comments/documentation, not in active color values
- `cat modules/home/ghostty.nix | grep "theme"` — Should NOT contain "Everforest Dark Hard"

## Notes

- **Rider IDE complexity**: The old rider.nix uses `dotnetCorePackages.sdk_7_0` which may need updating to `dotnetCorePackages.sdk_8_0` depending on current nixpkgs availability. Check before building. Also uses `xorg.libX11`, `xorg.libXcursor`, `xorg.libXrandr` which have deprecation warnings — may need to be updated to `libx11`, `libxcursor`, `libxrandr`.
- **VSCode Remote is WSL-only**: This module should NOT be imported in `default.nix` (desktop/VMware hosts). It goes in `default.wsl.nix` only. The vmware-guest build won't include it.
- **Sidecar package availability**: Verify `pkgs.sidecar` exists in current nixpkgs. If not, it may need to be installed via a different method (overlay, flake input, or manual installation).
- **TD package availability**: Verify `pkgs.td` exists in current nixpkgs. If not available, remove from packages and rely on the TD tool integration in CLAUDE.md instead.
- **DiscoCSS availability**: Verify `pkgs.discocss` exists in current nixpkgs unstable. If not available, consider alternative CSS injection methods (BetterDiscord, Vencord).
- **Nvim colorscheme**: The current neovim config likely uses an Everforest theme plugin. Check what nvf theme options are available for Osaka Jade or a similar dark-green colorscheme. If no exact match exists, consider using a custom lua colorscheme or the closest available option.
- **German keyboard layout**: `kb_layout = "de"` — no impact on any of these features.
- **All executables in Hyprland configs MUST use full nix store paths** `${pkgs.xxx}/bin/xxx` per project conventions.
- **Sub-agents via Task tool do NOT persist file writes to disk** — the team lead must verify agent outputs and apply changes manually if needed.
- **Theme migration is the riskiest task** — touching 16+ files with color replacements. The validator-theme agent should be thorough in checking for missed replacements and broken syntax.
- **Packages already present**: The exploration report incorrectly identified some packages as missing. The following are already in `packages.nix` and do NOT need migration: `easyeffects`, `gimp`, `thunderbird`, `onefetch`, `dconf-editor`, `wine` (as `wineWow64Packages.wayland`), `tldr` (as `tealdeer`).
