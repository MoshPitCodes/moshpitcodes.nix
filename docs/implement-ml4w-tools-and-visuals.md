# Plan: Implement ML4W Tools and Visuals

## Task Description
Port the tools, visual components, and UX patterns from [mylinuxforwork/dotfiles](https://github.com/mylinuxforwork/dotfiles/tree/main/dotfiles/.config) into our NixOS + Home Manager configuration. This involves upgrading Hyprland animations, decorations, keybindings, window rules, and idle behavior; implementing the ML4W-modern waybar theme; adding wlogout power menu; enhancing the rofi launcher with clipboard and screenshot configs; styling swaync notifications; configuring fastfetch; and adding missing utility packages.

## Objective
When complete, the NixOS vmware-guest (and all future hosts) will have a polished, ML4W-inspired desktop experience with:
- Smooth material-style animations (End-4 bezier curves)
- Enhanced decorations (blur, rounding, opacity, shadows)
- ML4W-modern waybar with bordered pill modules and hover effects
- wlogout power menu (lock, logout, suspend, reboot, shutdown)
- Styled rofi launcher with clipboard history mode
- Themed swaync notification center with quick-toggle buttons
- Fastfetch system info display
- Extended keybindings (window resize, workspace cycling, media keys, screenshots)
- All using the existing ristretto color palette

## Problem Statement
The current config has basic Hyprland functionality but lacks the polish and tooling of a complete desktop environment. Animations are simple, there's no power menu, no notification styling, no fastfetch config, rofi uses a generic theme, keybindings are minimal, and window decorations don't use blur/opacity effectively.

## Solution Approach
Translate each ML4W `.config` component into idiomatic NixOS/Home Manager Nix modules, using full nix store paths for all executables, and applying the ristretto color palette (`#2c2525` bg, `#e6d9db` fg, `#fd6883` accent, `#5b4a45` border) consistently. Skip ML4W-specific tooling (ml4w-settings app, waypaper, matugen) that requires Arch-specific packages.

## Relevant Files
Use these files to complete the task:

### Existing Files to Modify
- `modules/home/hyprland/default.nix` - Upgrade animations, decorations, keybindings, window rules, resize binds, exec-once
- `modules/home/hypridle.nix` - Add brightness dimming listener, suspend listener, improved lock command
- `modules/home/hyprlock.nix` - Add user label, improve input field styling with shadows
- `modules/home/waybar/default.nix` - Complete rewrite to ML4W-modern theme
- `modules/home/packages.nix` - Add wlogout, playerctl, brightnessctl, hyprpicker, swappy packages
- `modules/home/default.nix` - Import new modules (wlogout, swaync, fastfetch, rofi)
- `modules/core/default.nix` - Import new core modules if needed

### New Files
- `modules/home/wlogout.nix` - Power menu with lock/logout/suspend/reboot/shutdown
- `modules/home/swaync.nix` - Notification center config with widgets and styling
- `modules/home/fastfetch.nix` - System info display with box-art layout
- `modules/home/rofi/default.nix` - Enhanced rofi config with clipboard history mode (replace inline rofi config from hyprland)

## Implementation Phases

### Phase 1: Foundation
- Add missing packages (wlogout, playerctl, brightnessctl, hyprpicker, swappy, libnotify)
- Create the rofi module with proper theming and clipboard history config
- Update hyprland animations to use End-4 material bezier curves

### Phase 2: Core Implementation
- Implement wlogout power menu module
- Implement swaync notification center module with styled config
- Implement fastfetch module with box-art layout
- Upgrade waybar to ML4W-modern theme (bordered pills, hover effects, app menu, hardware group)
- Upgrade hyprland decorations (blur passes, opacity, shadows)
- Upgrade hyprland keybindings (resize, workspace cycling, media keys, wlogout trigger)
- Add hyprland window rules (floating dialogs, opacity rules)

### Phase 3: Integration & Polish
- Update hypridle with multi-stage listeners (brightness dim, lock, dpms off, suspend)
- Update hyprlock with user label, shadow effects
- Wire all new modules into default.nix imports
- Verify build passes with `nix build`
- Verify `nix flake check` passes

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
  - Name: engineer-hyprland
  - Role: Upgrade Hyprland animations, decorations, keybindings, window rules, and exec-once autostart
  - Agent Type: nixos
  - Resume: true

- Builder
  - Name: validator-hyprland
  - Role: Validate hyprland module changes build correctly and follow NixOS/Home Manager patterns
  - Agent Type: validator
  - Resume: true

- Builder
  - Name: engineer-waybar
  - Role: Rewrite waybar to ML4W-modern theme with ristretto colors
  - Agent Type: nixos
  - Resume: true

- Builder
  - Name: validator-waybar
  - Role: Validate waybar module builds and CSS is well-formed
  - Agent Type: validator
  - Resume: true

- Builder
  - Name: engineer-desktop-tools
  - Role: Create wlogout, swaync, fastfetch, and rofi modules
  - Agent Type: nixos
  - Resume: true

- Builder
  - Name: validator-desktop-tools
  - Role: Validate all new desktop tool modules build correctly and are properly imported
  - Agent Type: validator
  - Resume: true

- Builder
  - Name: engineer-idle-lock
  - Role: Upgrade hypridle and hyprlock with ML4W patterns
  - Agent Type: nixos
  - Resume: true

- Builder
  - Name: validator-idle-lock
  - Role: Validate hypridle/hyprlock changes build correctly
  - Agent Type: validator
  - Resume: true

- Builder
  - Name: engineer-packages
  - Role: Add all missing packages and update default.nix imports
  - Agent Type: nixos
  - Resume: true

- Builder
  - Name: validator-final
  - Role: Run full build validation and flake check on the complete config
  - Agent Type: validator
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

### 1. Add Missing Packages
- **Task ID**: add-packages
- **Depends On**: none
- **Assigned To**: engineer-packages
- **Agent Type**: nixos
- **Parallel**: true (can run alongside task 2-4)
- Add to `modules/home/packages.nix`: wlogout, playerctl, brightnessctl, hyprpicker, swappy, libnotify, pamixer
- Update `modules/home/default.nix` to import all new modules: `./wlogout.nix`, `./swaync.nix`, `./fastfetch.nix`, `./rofi` (replace inline rofi from hyprland)
- Update `modules/core/default.nix` if any system-level changes needed

### 2. Upgrade Hyprland Animations, Decorations & Keybindings
- **Task ID**: upgrade-hyprland
- **Depends On**: none
- **Assigned To**: engineer-hyprland
- **Agent Type**: nixos
- **Parallel**: true
- Replace animations block with End-4 material bezier curves (md3_standard, md3_decel, md3_accel, overshot, menu_decel, menu_accel, easeOutCirc, softAcDecel)
- Add animation configs: windows popin 60%, fade, layersIn/Out slide, workspaces slide
- Upgrade decorations: `rounding = 10`, `active_opacity = 1.0`, `inactive_opacity = 0.9`, blur `size = 4, passes = 4, new_optimizations = true, ignore_opacity = true, xray = true`, shadow `range = 32, render_power = 2, color = rgba(00000050)`
- Update general: `gaps_in = 10`, `gaps_out = 20`, `border_size = 1`, `resize_on_border = true`
- Add keybindings:
  - `$mod, T, togglefloating` (replace V)
  - `$mod SHIFT, Q, exec, hyprctl activewindow | grep pid | tr -d 'pid:' | xargs kill` (force quit)
  - `$mod, M, fullscreen, 1` (maximize)
  - `$mod SHIFT, right/left/up/down, resizeactive, ±100 0 / 0 ±100` (resize with keyboard)
  - `$mod, G, togglegroup` (window groups)
  - `$mod, K, swapsplit`
  - `$mod ALT, left/right/up/down, swapwindow, l/r/u/d`
  - `ALT, Tab, cyclenext` + `bringactivetotop`
  - `$mod, Tab, workspace, m+1` / `$mod SHIFT, Tab, workspace, m-1` (workspace cycling)
  - `$mod CTRL, Q, exec, wlogout` (power menu)
  - `$mod SHIFT, B, exec, pkill waybar && waybar` (reload waybar)
  - Volume: `XF86AudioRaiseVolume/LowerVolume/Mute` with wpctl/pactl
  - Media: `XF86AudioPlay/Next/Prev` with playerctl
  - `$mod, B, exec, firefox` (browser shortcut)
- Add window rules for floating dialogs (file picker, pavucontrol)
- Use full nix store paths for ALL executables (critical NixOS pattern)

### 3. Validate Hyprland Changes
- **Task ID**: validate-hyprland
- **Depends On**: upgrade-hyprland
- **Assigned To**: validator-hyprland
- **Agent Type**: validator
- **Parallel**: false
- Read `modules/home/hyprland/default.nix` and verify:
  - All executables use full nix store paths (`${pkgs.xxx}/bin/xxx`)
  - Animation beziers and configs are syntactically correct for Nix
  - Keybindings don't conflict
  - Window rules use correct Hyprland syntax
- Run `nix eval .#nixosConfigurations.vmware-guest.config.system.build.toplevel --no-build` to check for eval errors

### 4. Rewrite Waybar to ML4W-Modern Theme
- **Task ID**: rewrite-waybar
- **Depends On**: none
- **Assigned To**: engineer-waybar
- **Agent Type**: nixos
- **Parallel**: true
- Implement ML4W-modern waybar theme in `modules/home/waybar/default.nix`
- Module layout:
  - Left: app menu (custom/appmenu with rofi), workspaces (bordered pill buttons with active highlight)
  - Center: hyprland/window (window title)
  - Right: pulseaudio, bluetooth, network, hardware group (cpu, memory, disk), tray, notification (swaync toggle), clock
- CSS style using ristretto-mapped material design color variables:
  - `@define-color background #2c2525`
  - `@define-color surface #3a2f2f`
  - `@define-color primary #fd6883`
  - `@define-color on_surface #e6d9db`
  - `@define-color on_primary #2c2525`
  - `@define-color primary_container #5b4a45`
  - `@define-color border_color #5b4a45`
  - `@define-color icon_color #e6d9db`
  - `@define-color error #fd6883`
- All modules get: `background-color: @background`, `border-radius: 8px`, `border: 2px solid @border_color`, `padding: 2px 10px`, `margin: 3px 10px 3px 0px`, hover with `background: @primary_container`, `border-color: @primary`
- Workspaces: bordered buttons, active gets `background: @primary`, `color: @on_primary`, `border-radius: 12px`
- Tooltips: `border-radius: 10px`, `background-color: @surface`, `border: 2px solid @border_color`
- Clock module as bordered pill on far right
- Use full nix store paths for all on-click commands

### 5. Validate Waybar Changes
- **Task ID**: validate-waybar
- **Depends On**: rewrite-waybar
- **Assigned To**: validator-waybar
- **Agent Type**: validator
- **Parallel**: false
- Read `modules/home/waybar/default.nix` and verify:
  - All CSS selectors are valid
  - All module names match between settings and style
  - On-click commands use full nix store paths
  - Color variables are consistently defined and used
- Run nix eval to check for syntax errors

### 6. Create Desktop Tool Modules (wlogout, swaync, fastfetch, rofi)
- **Task ID**: create-desktop-tools
- **Depends On**: none
- **Assigned To**: engineer-desktop-tools
- **Agent Type**: nixos
- **Parallel**: true
- **wlogout.nix**: Create `modules/home/wlogout.nix`
  - Enable wlogout via Home Manager (`programs.wlogout` or xdg.configFile)
  - Layout: lock, logout, suspend, reboot, shutdown (5 buttons)
  - Actions use full nix store paths: `hyprlock`, `hyprctl dispatch exit`, `systemctl suspend`, `systemctl reboot`, `systemctl poweroff`
  - Style with ristretto colors (dark bg, light text, rounded buttons)
- **swaync.nix**: Create `modules/home/swaync.nix`
  - Use `xdg.configFile` for config.json and style.css
  - Config: position right/top, 360px width, widgets (dnd, buttons-grid, volume, mpris, title, notifications)
  - Buttons-grid: wifi toggle (nmcli), bluetooth toggle (rfkill), mute toggle (pactl), lock (hyprlock)
  - Style with ristretto colors, rounded corners, translucent background
- **fastfetch.nix**: Create `modules/home/fastfetch.nix`
  - Use `xdg.configFile` for config.jsonc
  - Box-art layout showing: user, hostname, uptime, distro, kernel, WM, terminal, shell, CPU, disk, memory, colors
  - Use NixOS logo instead of ML4W logo
- **rofi/default.nix**: Create `modules/home/rofi/default.nix` (replace inline rofi in hyprland)
  - Main config: drun mode, JetBrainsMono Nerd Font, show-icons, ristretto colors
  - Clipboard history config (config-cliphist.rasi equivalent)
  - Rounded elements with pill-shaped search bar
  - Colors: background `#2c2525`, surface `#3a2f2f`, on-surface `#e6d9db`, primary `#fd6883`
  - Remove rofi config from hyprland/default.nix (it moves to its own module)

### 7. Validate Desktop Tool Modules
- **Task ID**: validate-desktop-tools
- **Depends On**: create-desktop-tools
- **Assigned To**: validator-desktop-tools
- **Agent Type**: validator
- **Parallel**: false
- Read all 4 new modules and verify:
  - Nix syntax is correct
  - All paths use nix store paths
  - xdg.configFile paths are correct
  - JSON configs are valid
  - CSS is well-formed
  - Modules are importable (function args match)
- Verify `modules/home/default.nix` imports all new modules
- Run nix eval

### 8. Upgrade Hypridle and Hyprlock
- **Task ID**: upgrade-idle-lock
- **Depends On**: none
- **Assigned To**: engineer-idle-lock
- **Agent Type**: nixos
- **Parallel**: true
- **hypridle.nix**: Multi-stage listeners:
  - 480s (8min): dim brightness to 10% (brightnessctl -s set 10), resume restores
  - 600s (10min): lock session (loginctl lock-session)
  - 660s (11min): dpms off, resume dpms on + brightness restore
  - 1800s (30min): suspend
  - Lock command: `pidof hyprlock || hyprlock` (avoid duplicates)
  - before_sleep_cmd: `loginctl lock-session`
  - after_sleep_cmd: `hyprctl dispatch dpms on`
- **hyprlock.nix**: Enhanced layout:
  - Background with blur (passes=2, size=4)
  - Input field with shadow, capslock warning, fail text
  - Time label (font_size 64)
  - User label showing `$USER` below clock
  - All ristretto colors

### 9. Validate Idle/Lock Changes
- **Task ID**: validate-idle-lock
- **Depends On**: upgrade-idle-lock
- **Assigned To**: validator-idle-lock
- **Agent Type**: validator
- **Parallel**: false
- Read both modules and verify syntax, nix store paths, listener timeouts
- Run nix eval

### 10. Final Build Validation
- **Task ID**: validate-final
- **Depends On**: add-packages, validate-hyprland, validate-waybar, validate-desktop-tools, validate-idle-lock
- **Assigned To**: validator-final
- **Agent Type**: validator
- **Parallel**: false
- Run `nix build .#nixosConfigurations.vmware-guest.config.system.build.toplevel` - must succeed
- Run `nix flake check` - must pass
- Verify no duplicate imports in default.nix files
- Verify no conflicting home.packages entries
- Verify all new modules are imported
- Report final status

## Acceptance Criteria
- `nix build .#nixosConfigurations.vmware-guest.config.system.build.toplevel` succeeds without errors
- `nix flake check` passes
- All new modules (wlogout, swaync, fastfetch, rofi) exist and are imported
- Hyprland has material animations (End-4 beziers), enhanced decorations, extended keybindings
- Waybar uses ML4W-modern theme with bordered pill modules and hover effects
- wlogout provides lock/logout/suspend/reboot/shutdown
- swaync has widget buttons (wifi, bluetooth, mute, lock)
- Fastfetch shows system info in box-art layout
- Rofi has styled launcher with clipboard history mode
- Hypridle has 4-stage timeout (dim, lock, dpms off, suspend)
- All executables use full nix store paths
- Ristretto color palette applied consistently across all components

## Validation Commands
Execute these commands to validate the task is complete:

- `nix build .#nixosConfigurations.vmware-guest.config.system.build.toplevel` - Full system build
- `nix flake check` - Flake integrity check
- `grep -r "import" modules/home/default.nix` - Verify all new modules are imported
- `grep -rn "pkgs\." modules/home/wlogout.nix modules/home/swaync.nix modules/home/fastfetch.nix modules/home/rofi/default.nix` - Verify nix store paths used

## Notes
- Skip ML4W-specific components: ml4w-settings app, ml4w-welcome, waypaper (Arch-only), matugen (dynamic theming), sidepad
- The ML4W config uses shell script wrappers for many actions (`~/.config/hypr/scripts/*`). We translate these to inline commands with full nix store paths instead.
- The ML4W waybar uses `@import` for colors from a theme system. We define `@define-color` variables directly in the CSS with ristretto values.
- wlogout may need system-level configuration for polkit if using suspend/reboot/shutdown. The vmware-guest host already has these available via systemd.
- The rofi config references ML4W-specific files for wallpaper backgrounds and font overrides. We strip these and use static ristretto colors instead.
- brightnessctl may not work in VMware guest. The hypridle brightness listeners will fail gracefully.
- playerctl requires a media player running. Media key bindings will be no-ops if no player is active.
