# Plan: Adopt Maciejonos Dotfiles - Remaining Gaps

## Task Description
Complete the adoption of the [maciejonos/dotfiles](https://github.com/Maciejonos/dotfiles) repository into our NixOS flake at `shifttab.nix`. The walker/elephant migration is done. This plan covers all remaining configuration gaps between the upstream Arch dotfiles and our NixOS Home Manager modules.

## Objective
Close every remaining gap between the maciejonos/dotfiles feature set and our NixOS config. After this plan is executed, our Hyprland desktop will match the upstream functionality — group borders, environment variables, polkit agent, waybar bluetooth/hypridle modules, and walker elephant menu integration — all declaratively managed by NixOS/Home Manager.

## Problem Statement
After the walker migration, these upstream features are still missing from our config:

1. **Hyprland group borders** - Active/inactive group border colors not set to osaka-jade
2. **Hyprland environment variables** - No Wayland/XDG session env vars (QT_QPA_PLATFORM, GDK_BACKEND, etc.)
3. **Polkit authentication agent** - No polkit agent autostarted for privileged operations
4. **GTK layer-shell layer rule** - Missing `no_anim` for gtk-layer-shell namespace
5. **Waybar bluetooth module** - No bluetooth status indicator in the bar
6. **Waybar hypridle toggle module** - No idle inhibitor toggle from the bar
7. **Walker elephant menus** - No elephant menu config for system-level menus (themes, capture, tools)

## Solution Approach
Enhance existing modules with targeted additions rather than creating new files. The walker.nix module gets an elephant config addition. Hyprland and waybar modules get the missing settings. No new module files needed.

## Relevant Files

**Files to modify:**
- `modules/home/hyprland/default.nix` — Add group borders, env vars, polkit autostart, gtk-layer-shell rule
- `modules/home/waybar/default.nix` — Add bluetooth module, hypridle toggle module, corresponding CSS
- `modules/home/walker.nix` — Add elephant config.toml for system menus

**Files already complete (no changes needed):**
- `modules/home/btop.nix` — osaka-jade theme fully applied
- `modules/home/swayosd.nix` — SwayOSD service + osaka-jade CSS
- `modules/home/ghostty.nix` — Full 16-color ANSI palette
- `modules/home/starship.nix` — Nerd font symbols preset + osaka-jade colors
- `modules/home/hyprlock.nix` — osaka-jade lock screen
- `modules/home/hypridle.nix` — 4-stage timeout with full store paths
- `modules/home/fastfetch.nix` — Catnap box-drawn layout
- `modules/home/theming.nix` — GTK 3/4 osaka-jade CSS + Bibata cursor
- `modules/home/swaync.nix` — osaka-jade notification center
- `modules/home/wlogout.nix` — osaka-jade power menu
- `modules/home/tmux.nix` — osaka-jade status bar
- `modules/home/media.nix` — osaka-jade zathura + mpv

**Upstream reference files:**
- `themes/osaka-jade/hyprland.conf` — Group border color (`rgb(71CEAD)`)
- `default/hypr/conf/env.conf` — Wayland/XDG environment variables
- `default/hypr/conf/autostart.conf` — Polkit agent startup
- `default/hypr/conf/layerrules.conf` — gtk-layer-shell no_anim rule
- `config/waybar/modules.json` — bluetooth and hypridle module definitions
- `config/waybar/config` — Module layout including bluetooth
- `config/elephant/` — Elephant menu definitions (menus/, bookmarks, symbols, etc.)

**Upstream features intentionally NOT adopted:**
- `mako` notifications — We use SwayNC (equivalent, already themed)
- `uwsm` session manager — Arch-specific, not needed on NixOS
- `matugen` dynamic theming — We use fixed osaka-jade theme
- `ly` display manager — We use greetd/tuigreet
- `neovim/lazyvim` — Not part of this user's workflow
- `icons.theme` (Yaru-sage) — We use Papirus-Dark
- `hyprpaper` wallpaper — Hyprland built-in wallpaper suffices; can add later
- `sunsetr` night light — Can add later as separate enhancement
- Arch-specific scripts (`pkg-install`, `pkg-remove`, `run-updates`, etc.)
- `battery` waybar module — VMware guest has no battery

## Implementation Phases

### Phase 1: Hyprland Enhancements
Add group border colors, Wayland environment variables, polkit agent autostart, and gtk-layer-shell layer rule to `modules/home/hyprland/default.nix`.

### Phase 2: Waybar Module Additions
Add bluetooth status indicator and hypridle toggle custom module to `modules/home/waybar/default.nix`, including corresponding CSS selectors.

### Phase 3: Elephant Menu Config
Add elephant `config.toml` via `xdg.configFile` in `modules/home/walker.nix` to enable system-level menus accessible through walker.

### Phase 4: Validation
Build all host configurations, verify no regressions, confirm osaka-jade consistency.

## Team Orchestration

- You operate as the team lead and orchestrate the team to execute the plan.
- IMPORTANT: You NEVER operate directly on the codebase. You use `Task` and `Task*` tools to deploy team members to do the building, validating, testing, deploying, and other tasks.

### Team Members

- Builder
  - Name: hyprland-builder
  - Role: Apply Hyprland enhancements (group borders, env vars, polkit, layer rules)
  - Agent Type: general-purpose
  - Resume: true

- Builder
  - Name: waybar-builder
  - Role: Add bluetooth and hypridle toggle modules to waybar with CSS
  - Agent Type: general-purpose
  - Resume: true

- Builder
  - Name: elephant-builder
  - Role: Add elephant config.toml for system menus in walker.nix
  - Agent Type: general-purpose
  - Resume: true

- Builder
  - Name: validator
  - Role: Run nix build, grep for consistency, verify acceptance criteria
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

This ensures full traceability from planning -> implementation -> validation.

## Step by Step Tasks

### 1. Add Hyprland Group Border Colors
- **Task ID**: hyprland-group-borders
- **Depends On**: none
- **Assigned To**: hyprland-builder
- **Agent Type**: general-purpose
- **Parallel**: true (can run alongside tasks 2-3)
- Read `modules/home/hyprland/default.nix`
- Add `group` settings block after `general` block:
  ```nix
  group = {
    "col.border_active" = "rgba(71CEADff)";
    "col.border_inactive" = "rgba(23372Bff)";
  };
  ```
- IMPORTANT: Preserve `kb_layout = "de"` (German layout) — do NOT change this
- IMPORTANT: All executables must use full nix store paths `${pkgs.xxx}/bin/xxx`

### 2. Add Hyprland Environment Variables
- **Task ID**: hyprland-env-vars
- **Depends On**: none
- **Assigned To**: hyprland-builder
- **Agent Type**: general-purpose
- **Parallel**: true (part of hyprland-builder's batch)
- Add `env` list to Hyprland settings:
  ```nix
  env = [
    "XDG_CURRENT_DESKTOP,Hyprland"
    "XDG_SESSION_TYPE,wayland"
    "XDG_SESSION_DESKTOP,Hyprland"
    "QT_QPA_PLATFORM,wayland"
    "GDK_BACKEND,wayland,x11,*"
    "SDL_VIDEODRIVER,wayland"
    "CLUTTER_BACKEND,wayland"
  ];
  ```
- NOTE: Do NOT add NVIDIA env vars — this is a VMware guest

### 3. Add GTK Layer-Shell Layer Rule
- **Task ID**: gtk-layer-shell-rule
- **Depends On**: none
- **Assigned To**: hyprland-builder
- **Agent Type**: general-purpose
- **Parallel**: true (part of hyprland-builder's batch)
- Add to the existing `layerrule` list:
  ```nix
  "no_anim 1, match:namespace ^(gtk-layer-shell)$"
  ```

### 4. Add Polkit Agent Autostart
- **Task ID**: polkit-autostart
- **Depends On**: none
- **Assigned To**: hyprland-builder
- **Agent Type**: general-purpose
- **Parallel**: true (part of hyprland-builder's batch)
- Add polkit-gnome agent to `exec-once` list:
  ```nix
  "${pkgs.polkit_gnome}/bin/polkit-gnome-authentication-agent-1"
  ```
- Verify the package attribute path is correct on nixpkgs unstable (may be `pkgs.polkit_gnome` or `pkgs.polkit-gnome-agent`)

### 5. Add Waybar Bluetooth Module
- **Task ID**: waybar-bluetooth
- **Depends On**: none
- **Assigned To**: waybar-builder
- **Agent Type**: general-purpose
- **Parallel**: true (can run alongside tasks 1-4)
- Read `modules/home/waybar/default.nix`
- Add `"bluetooth"` to `modules-right` list between `"network"` and `"cpu"`
- Add bluetooth module configuration:
  ```nix
  bluetooth = {
    format = "";
    format-disabled = "󰂲";
    format-connected = "";
    tooltip-format = "Devices connected: {num_connections}";
    on-click = "${pkgs.ghostty}/bin/ghostty -e ${pkgs.bluetuith}/bin/bluetuith";
  };
  ```
- Verify `bluetuith` package exists in nixpkgs; if not, use `blueman` or omit `on-click`
- Add `#bluetooth` to the CSS selector group alongside `#cpu`, `#pulseaudio`, `#network`, etc.

### 6. Add Waybar Hypridle Toggle Module
- **Task ID**: waybar-hypridle-toggle
- **Depends On**: none
- **Assigned To**: waybar-builder
- **Agent Type**: general-purpose
- **Parallel**: true (part of waybar-builder's batch)
- Add `"custom/hypridle"` to `modules-right` after `"cpu"`, before `"tray"`
- Add custom module configuration:
  ```nix
  "custom/hypridle" = {
    format = "{}";
    return-type = "json";
    escape = true;
    exec-on-event = true;
    interval = 60;
    exec = "${pkgs.writeShellScript "hypridle-status" ''
      if ${pkgs.procps}/bin/pgrep -x hypridle > /dev/null; then
        echo '{"text": "", "class": "active", "tooltip": "Idle: active"}'
      else
        echo '{"text": "", "class": "notactive", "tooltip": "Idle: inactive"}'
      fi
    ''}";
    on-click = "${pkgs.writeShellScript "hypridle-toggle" ''
      if ${pkgs.procps}/bin/pgrep -x hypridle > /dev/null; then
        ${pkgs.procps}/bin/pkill hypridle
      else
        ${pkgs.hypridle}/bin/hypridle &
      fi
    ''}";
  };
  ```
- Add CSS for `#custom-hypridle` selector in the module group
- Add inactive state styling:
  ```css
  #custom-hypridle.notactive {
    color: rgb(224, 137, 137);
  }
  ```

### 7. Add Elephant Configuration
- **Task ID**: elephant-config
- **Depends On**: none
- **Assigned To**: elephant-builder
- **Agent Type**: general-purpose
- **Parallel**: true (can run alongside all other tasks)
- Read `modules/home/walker.nix`
- Add `xdg.configFile."elephant/config.toml"` with basic elephant config adapted from upstream:
  - Desktop applications provider
  - Clipboard provider (integrates with cliphist)
  - Files provider
  - Runner provider
  - Symbols provider
  - Calculator provider
  - Web search provider
- Strip Arch-specific elephant menus (package management, docker setup, postgres management)
- Keep universal menus: keybindings reference, capture/screenshot, system power options
- Ensure elephant config references correct nix store paths where applicable

### 8. Validate Build
- **Task ID**: validate-all
- **Depends On**: hyprland-group-borders, hyprland-env-vars, gtk-layer-shell-rule, polkit-autostart, waybar-bluetooth, waybar-hypridle-toggle, elephant-config
- **Assigned To**: validator
- **Agent Type**: general-purpose
- **Parallel**: false
- Run `nix build .#nixosConfigurations.vmware-guest.config.system.build.toplevel`
- Verify no build errors
- Run grep to confirm osaka-jade color consistency across all modified modules
- Verify German keyboard layout `kb_layout = "de"` is preserved
- Verify all executables use full nix store paths
- Verify no rofi references remain anywhere in `.nix` files

## Acceptance Criteria
- [ ] Hyprland group borders use osaka-jade active color (`71CEAD`) and inactive color (`23372B`)
- [ ] Wayland/XDG environment variables set in Hyprland config (XDG_CURRENT_DESKTOP, QT_QPA_PLATFORM, etc.)
- [ ] Polkit authentication agent starts with Hyprland session
- [ ] GTK layer-shell has `no_anim` layer rule
- [ ] Waybar shows bluetooth status icon with click-to-open bluetuith
- [ ] Waybar shows hypridle toggle icon with active/inactive visual states
- [ ] Elephant has a config.toml deployed via xdg.configFile
- [ ] `nix build .#nixosConfigurations.vmware-guest.config.system.build.toplevel` succeeds
- [ ] All executables use full nix store paths (`${pkgs.xxx}/bin/xxx`)
- [ ] German keyboard layout (`kb_layout = "de"`) preserved
- [ ] No regressions to existing osaka-jade themed modules
- [ ] No rofi references remain in any `.nix` file

## Validation Commands
Execute these commands to validate the task is complete:

- `nix build .#nixosConfigurations.vmware-guest.config.system.build.toplevel` — Full configuration build
- `grep -r "kb_layout" modules/home/hyprland/` — Verify German keyboard layout preserved
- `grep -r "71CEAD" modules/home/hyprland/default.nix` — Verify jade accent in group borders
- `grep -r "XDG_CURRENT_DESKTOP" modules/home/hyprland/default.nix` — Verify env vars present
- `grep -r "polkit" modules/home/hyprland/default.nix` — Verify polkit agent in autostart
- `grep -r "bluetooth" modules/home/waybar/default.nix` — Verify bluetooth module added
- `grep -r "hypridle" modules/home/waybar/default.nix` — Verify hypridle toggle added
- `grep -r "elephant" modules/home/walker.nix` — Verify elephant config present
- `grep -rn "rofi" modules/ --include="*.nix"` — Verify no rofi references remain

## Notes
- Walker migration is complete — `modules/home/walker.nix` has walker + elephant packages, osaka-jade theme CSS/XML, and config.toml
- We use SwayNC instead of upstream's Mako for notifications — both are fully themed, no change needed
- We use greetd/tuigreet instead of upstream's Ly display manager — NixOS native approach
- UWSM is Arch-specific session management — not needed on NixOS where Hyprland is managed by the module system
- Matugen dynamic theming is not adopted — our fixed osaka-jade theme is applied consistently; dynamic theming can be a future enhancement
- Hyprpaper wallpaper daemon is not adopted — can be added as a separate enhancement if desired
- Sunsetr night light is not adopted — can be added as a separate enhancement
- The upstream `bin/` scripts are Arch-specific (pacman, yay) and not applicable to NixOS
- `bluetuith` package availability should be verified in nixpkgs; fallback to removing `on-click` if unavailable
- Polkit package attribute path may vary between nixpkgs versions — verify `pkgs.polkit_gnome` vs alternatives
