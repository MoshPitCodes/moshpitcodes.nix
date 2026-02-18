# Plan: Migrate Wallpaper Management from Old Config

## Task Description
Migrate the full wallpaper management system from the old NixOS config (`moshpitcodes.nix-main`) to the current config (`shifttab.nix`). The old config used swww (animated wallpaper daemon) with waypaper (GUI picker), custom scripts, keybindings, and waybar integration. The current config has hyprpaper enabled but all copied scripts reference swww, wall-change isn't packaged, no keybindings exist, and paths are mismatched — making the wallpaper system completely non-functional.

## Objective
A fully working wallpaper management system with:
- swww daemon with animated transition effects (wipe, fade)
- waypaper GUI wallpaper picker
- Rofi/walker-based quick wallpaper picker script
- Random wallpaper script
- Hyprland keybindings (Super+W, Super+Shift+W)
- Standardized wallpaper directory at `~/Pictures/wallpapers/`

## Problem Statement
The current wallpaper setup is broken:
1. `hyprpaper.nix` is enabled but points to `~/wallpapers/default.jpg`
2. Scripts (`wall-change.sh`, `wallpaper-picker.sh`, `random-wallpaper.sh`) all use `swww` which is NOT installed
3. `wall-change` script is NOT packaged in `scripts/default.nix` (missing from home.packages)
4. No wallpaper keybindings in Hyprland config
5. No waypaper GUI or config
6. No waybar wallpaper button
7. Path mismatch: hyprpaper uses `~/wallpapers/`, scripts use `~/Pictures/wallpapers/`

## Solution Approach
Replace hyprpaper with swww + waypaper (matching old config), fix all scripts to be properly packaged with correct dependencies, add keybindings, and standardize on `~/Pictures/wallpapers/` directory. The wallpaper-picker script will be updated to use walker instead of rofi (since walker replaced rofi in this config).

## Relevant Files

**Files to Modify:**
- `modules/home/hyprpaper.nix` — Remove or disable hyprpaper (replaced by swww)
- `modules/home/hyprland/default.nix` — Add swww-daemon to exec-once, add wallpaper keybindings, add waypaper window rules
- `modules/home/scripts/default.nix` — Package wall-change with swww runtimeInput, ensure all wallpaper scripts are in home.packages
- `modules/home/scripts/scripts/wallpaper-picker.sh` — Update to use walker instead of rofi
- `modules/home/scripts/scripts/wall-change.sh` — Already correct (uses swww), no changes needed
- `modules/home/scripts/scripts/random-wallpaper.sh` — Already correct, no changes needed

### New Files
- `modules/home/waypaper.nix` — Waypaper GUI config with swww backend (from old config, adapted for VMware single monitor)

**Reference Files (old config):**
- `/home/moshpitcodes/Development/moshpitcodes.nix-main/modules/home/waypaper.nix` — Old waypaper config
- `/home/moshpitcodes/Development/moshpitcodes.nix-main/modules/home/hyprland/config.nix` — Old keybindings and exec-once

## Implementation Phases

### Phase 1: Foundation
- Disable hyprpaper, install swww + waypaper packages
- Package wall-change script with swww runtimeInput

### Phase 2: Core Implementation
- Create waypaper.nix with config adapted for current setup (VMware single monitor)
- Update wallpaper-picker.sh to use walker instead of rofi
- Add swww-daemon to Hyprland exec-once with initial wallpaper set
- Add keybindings for Super+W (picker) and Super+Shift+W (waypaper GUI)
- Add waypaper window rules (float, pin)

### Phase 3: Integration & Polish
- Ensure wallpaper directory exists (`~/Pictures/wallpapers/`)
- Validate build compiles
- Test all keybindings and scripts work together

## Team Orchestration

- You operate as the team lead and orchestrate the team to execute the plan.
- You're responsible for deploying the right team members with the right context to execute the plan.
- IMPORTANT: You NEVER operate directly on the codebase. You use `Task` and `Task*` tools to deploy team members to to the building, validating, testing, deploying, and other tasks.

### Team Members

- Builder
  - Name: builder-wallpaper
  - Role: Implement the wallpaper management migration (modify/create all Nix modules and scripts)
  - Agent Type: general-purpose
  - Resume: true

- Builder
  - Name: builder-hyprland
  - Role: Update Hyprland configuration (exec-once, keybindings, window rules)
  - Agent Type: general-purpose
  - Resume: true

- Builder
  - Name: validator-nix
  - Role: Validate the full NixOS configuration builds successfully
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

### 1. Disable Hyprpaper and Install swww/waypaper Packages
- **Task ID**: disable-hyprpaper
- **Depends On**: none
- **Assigned To**: builder-wallpaper
- **Agent Type**: general-purpose
- **Parallel**: true
- Edit `modules/home/hyprpaper.nix`: set `services.hyprpaper.enable = false;` and add comment explaining swww is used instead
- Alternatively, keep the file but disable the service so it's clear what replaced it

### 2. Create Waypaper Configuration
- **Task ID**: create-waypaper
- **Depends On**: disable-hyprpaper
- **Assigned To**: builder-wallpaper
- **Agent Type**: general-purpose
- **Parallel**: false
- Create `modules/home/waypaper.nix` based on old config at `/home/moshpitcodes/Development/moshpitcodes.nix-main/modules/home/waypaper.nix`
- Install `pkgs.waypaper` and `pkgs.swww` packages
- Configure waypaper with swww backend
- Adapt monitor sections for VMware (single `Virtual-1` monitor instead of DP-5/6/7/eDP-1)
- Set wallpaper folder to `~/Pictures/wallpapers/`
- Set swww transition: type=wipe, duration=2, fps=60, angle=30, step=90
- Add import to `modules/home/default.nix`

### 3. Fix Scripts Packaging
- **Task ID**: fix-scripts
- **Depends On**: disable-hyprpaper
- **Assigned To**: builder-wallpaper
- **Agent Type**: general-purpose
- **Parallel**: true (can run alongside create-waypaper)
- In `modules/home/scripts/default.nix`:
  - Add `wall-change` script using `pkgs.writeShellApplication` with `runtimeInputs = [ pkgs.swww pkgs.procps ]` (matching old config pattern)
  - Ensure `wall-change` is added to `home.packages`
  - Verify `wallpaper-picker` and `random-wallpaper` are in `home.packages` (they are)
- Update `modules/home/scripts/scripts/wallpaper-picker.sh`:
  - Replace `rofi -dmenu` with walker-based selection (or keep rofi since walker may not support dmenu mode — check walker docs)
  - Alternative: use `walker -m dmenu` if supported, otherwise keep simple `ls | rofi -dmenu` pattern

### 4. Update Hyprland Configuration
- **Task ID**: update-hyprland
- **Depends On**: fix-scripts, create-waypaper
- **Assigned To**: builder-hyprland
- **Agent Type**: general-purpose
- **Parallel**: false
- In `modules/home/hyprland/default.nix`:
  - Add to `exec-once`:
    ```nix
    "${pkgs.swww}/bin/swww-daemon"
    "sleep 1 && ${pkgs.swww}/bin/swww img ~/Pictures/wallpapers/default.jpg --transition-type wipe --transition-duration 1"
    ```
  - Add keybindings to `bind`:
    ```nix
    "$mod, W, exec, wallpaper-picker"
    "$mod SHIFT, W, exec, ${pkgs.hyprland}/bin/hyprctl dispatch exec '[float; size 925 615] ${pkgs.waypaper}/bin/waypaper'"
    ```
  - Add window rules for waypaper:
    ```nix
    "float on, match:class ^(waypaper)$"
    "pin on, match:class ^(waypaper)$"
    ```

### 5. Create Wallpaper Directory
- **Task ID**: create-wallpaper-dir
- **Depends On**: none
- **Assigned To**: builder-wallpaper
- **Agent Type**: general-purpose
- **Parallel**: true
- Add `~/Pictures/wallpapers/` directory creation via `home.file` or activation script
- Ensure `~/Pictures/wallpapers/randomwallpaper/` subdirectory exists (used by random-wallpaper.sh)
- OR: Document in notes that user must create `~/Pictures/wallpapers/` and add images

### 6. Validate Build
- **Task ID**: validate-all
- **Depends On**: disable-hyprpaper, create-waypaper, fix-scripts, update-hyprland, create-wallpaper-dir
- **Assigned To**: validator-nix
- **Agent Type**: general-purpose
- **Parallel**: false
- Run `nix build .#nixosConfigurations.vmware-guest.config.system.build.toplevel`
- Verify no build errors
- Verify swww and waypaper packages are in the closure
- Verify wall-change, wallpaper-picker, random-wallpaper scripts are available

## Acceptance Criteria
- [ ] `services.hyprpaper` is disabled (or hyprpaper.nix removed/replaced)
- [ ] `pkgs.swww` and `pkgs.waypaper` are installed
- [ ] `waypaper.nix` exists with swww backend configuration
- [ ] `wall-change` script is properly packaged with swww as runtimeInput
- [ ] `wallpaper-picker.sh` works with current launcher (walker or rofi)
- [ ] Hyprland exec-once starts swww-daemon and sets initial wallpaper
- [ ] `Super+W` keybinding launches wallpaper picker
- [ ] `Super+Shift+W` keybinding launches waypaper GUI (floating)
- [ ] Waypaper window rule: float + pin
- [ ] All wallpaper paths use `~/Pictures/wallpapers/`
- [ ] `nix build .#nixosConfigurations.vmware-guest.config.system.build.toplevel` succeeds
- [ ] No hyprpaper service running (replaced by swww)

## Validation Commands
Execute these commands to validate the task is complete:

- `nix build .#nixosConfigurations.vmware-guest.config.system.build.toplevel` — Full system build must succeed
- `grep -r "swww" modules/home/hyprland/default.nix` — Verify swww-daemon in exec-once
- `grep -r "wallpaper-picker\|waypaper" modules/home/hyprland/default.nix` — Verify keybindings exist
- `grep -r "wall-change" modules/home/scripts/default.nix` — Verify wall-change is packaged
- `grep -r "swww" modules/home/scripts/default.nix` — Verify swww runtimeInput for wall-change
- `grep -r "waypaper" modules/home/waypaper.nix` — Verify waypaper config exists
- `cat modules/home/hyprpaper.nix | grep "enable = false"` — Verify hyprpaper disabled

## Notes
- The old config used `rofi -dmenu` for wallpaper picker. Since rofi was replaced by walker in this config, wallpaper-picker.sh needs to be adapted. Walker supports `-m dmenu` mode but verify syntax.
- The old config had per-monitor wallpaper sections in waypaper config (DP-5, DP-6, DP-7, eDP-1). The VMware guest only has a single virtual monitor, so simplify to a single monitor section.
- swww transitions (wipe effect) require a running swww-daemon — must be started BEFORE any `swww img` calls in exec-once. The `sleep 1` delay ensures the daemon is ready.
- The `wall-change` script in the old config was packaged using `pkgs.writeShellApplication` with `runtimeInputs = [ pkgs.swww pkgs.procps ]` — this ensures swww and pgrep are in PATH when the script runs. This is critical and must be replicated.
- Keep hyprpaper.nix file with `enable = false` rather than deleting it, in case user wants to switch back later.
- German keyboard layout (`kb_layout = "de"`) — no impact on wallpaper management.
- All executables in Hyprland configs MUST use full nix store paths `${pkgs.xxx}/bin/xxx` per project conventions.
