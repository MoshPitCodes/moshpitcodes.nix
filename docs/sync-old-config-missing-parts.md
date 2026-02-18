# Plan: Sync Missing Parts from Old Config

## Task Description
Thorough comparison of `~/Development/moshpitcodes.nix-main` (old config) vs `~/Development/shifttab.nix` (current config) has been completed. This plan captures all missing or replaced pieces and defines tasks to bring the current config to full feature parity with the old config, while keeping intentional improvements (Everforest theme, walker, nautilus, consolidated modules).

## Objective
Restore all missing functional pieces from the old config into the current config without reverting intentional improvements. After completion, the current config should have full feature parity with the old config.

## Problem Statement
The current config was rebuilt from scratch with a different structure and some features were lost or incomplete during migration. Key areas affected: development tooling, zsh configuration, Hyprland keybinds/settings/autostart, window rules, and packages.

## Solution Approach
Work through each category of missing items in priority order. Use the old config files as reference, but adapt to the current config's patterns (full nix store paths, Everforest theme, walker instead of rofi, nautilus instead of nemo, consolidated module structure).

## Relevant Files

### Old Config Reference Files
- `~/Development/moshpitcodes.nix-main/modules/home/hyprland/config.nix` — Full Hyprland settings, keybinds, window rules, autostart
- `~/Development/moshpitcodes.nix-main/modules/home/hyprland/variables.nix` — Session environment variables
- `~/Development/moshpitcodes.nix-main/modules/home/development/development.nix` — Development packages and SDKs
- `~/Development/moshpitcodes.nix-main/modules/home/zsh/zsh.nix` — Zsh plugins, FZF-Tab, init logic
- `~/Development/moshpitcodes.nix-main/modules/home/zsh/zsh_alias.nix` — All shell aliases
- `~/Development/moshpitcodes.nix-main/modules/home/zsh/zsh_keybinds.nix` — Zsh key bindings
- `~/Development/moshpitcodes.nix-main/modules/home/packages.nix` — Package list
- `~/Development/moshpitcodes.nix-main/modules/home/nemo.nix` — File manager config (reference only)
- `~/Development/moshpitcodes.nix-main/modules/home/gtk.nix` — GTK theme config (reference only)

### Current Config Files to Modify
- `modules/home/hyprland/default.nix` — Add missing keybinds, window rules, autostart items, misc settings
- `modules/home/development/development.nix` — Add missing dev tools
- `modules/home/zsh/default.nix` — Add missing aliases, FZF-Tab, SSH/GPG init logic
- `modules/home/packages.nix` — Add missing packages

## Implementation Phases

### Phase 1: Foundation (Critical Fixes)
Restore functional items that affect daily use: Hyprland autostart services, dbus environment, keybinds.

### Phase 2: Core Implementation (Feature Parity)
Restore development tools, zsh aliases/plugins, window rules, workspace assignments.

### Phase 3: Integration & Polish
Verify builds, test configuration, add missing minor settings.

## Team Orchestration

- You operate as the team lead and orchestrate the team to execute the plan.
- IMPORTANT: You NEVER operate directly on the codebase. You use `Task` and `Task*` tools to deploy team members.

### Team Members

- Builder
  - Name: builder-hyprland
  - Role: Restore all missing Hyprland configuration (keybinds, window rules, autostart, misc settings)
  - Agent Type: general-purpose
  - Resume: true

- Builder
  - Name: builder-devtools
  - Role: Restore missing development packages and tools
  - Agent Type: general-purpose
  - Resume: true

- Builder
  - Name: builder-zsh
  - Role: Restore missing zsh aliases, FZF-Tab integration, SSH/GPG init logic
  - Agent Type: general-purpose
  - Resume: true

- Builder
  - Name: builder-packages
  - Role: Fix missing packages and minor config items
  - Agent Type: general-purpose
  - Resume: true

- Builder
  - Name: validator
  - Role: Validate all changes build successfully for both vmware-guest and laptop hosts
  - Agent Type: general-purpose
  - Resume: true

### TD Task Integration

**IMPORTANT**: Team members (builder, validator) use TD MCP tools to track their work when available.

## Step by Step Tasks

### 1. Restore Hyprland Autostart Services
- **Task ID**: hyprland-autostart
- **Depends On**: none
- **Assigned To**: builder-hyprland
- **Agent Type**: general-purpose
- **Parallel**: true
- Read old `~/Development/moshpitcodes.nix-main/modules/home/hyprland/config.nix` exec-once section (lines 5-22)
- Add to `modules/home/hyprland/default.nix` exec-once:
  - `easyeffects --gapplication-service` (audio effects daemon — use `${pkgs.easyeffects}/bin/easyeffects --gapplication-service`)
  - `poweralertd` (battery alert daemon — use `${pkgs.poweralertd}/bin/poweralertd`)
  - `hyprctl setcursor Bibata-Modern-Ice 24` (cursor init — use `${pkgs.hyprland}/bin/hyprctl setcursor Bibata-Modern-Ice 24`)
- Do NOT add back `nm-applet` (replaced by waybar network module)
- Do NOT add back `hyprlock` autostart (handled by hypridle)
- Do NOT add `dbus-update-activation-environment` (handled by UWSM in current config)

### 2. Restore Missing Hyprland Misc Settings
- **Task ID**: hyprland-misc
- **Depends On**: none
- **Assigned To**: builder-hyprland
- **Agent Type**: general-purpose
- **Parallel**: true
- Read old `~/Development/moshpitcodes.nix-main/modules/home/hyprland/config.nix` (lines 24-70)
- Add to `modules/home/hyprland/default.nix` settings:
  - `input.numlock_by_default = true;`
  - `input.repeat_delay = 300;`
  - `input.accel_profile = "flat";`
  - `input.float_switch_override_focus = 0;`
  - `input.mouse_refocus = 0;`
  - `misc.enable_swallow = true;`
  - `misc.focus_on_activate = true;`
  - `misc.middle_click_paste = false;`
  - `misc.layers_hog_keyboard_focus = true;`
  - `dwindle.force_split = 2;`

### 3. Restore Missing Hyprland Keybinds
- **Task ID**: hyprland-keybinds
- **Depends On**: none
- **Assigned To**: builder-hyprland
- **Agent Type**: general-purpose
- **Parallel**: true
- Read old `~/Development/moshpitcodes.nix-main/modules/home/hyprland/config.nix` bind section (lines 133-262)
- Add missing keybinds to `modules/home/hyprland/default.nix`:
  - **hjkl navigation**: `$mod, h/j/k/l, movefocus, l/d/u/r`
  - **hjkl window move**: `$mod SHIFT, h/j/k/l, movewindow, l/d/u/r`
  - **hjkl resize**: `$mod CTRL, h/j/k/l, resizeactive, -80 0/0 80/0 -80/80 0`
  - **hjkl move floating**: `$mod ALT, h/j/k/l, moveactive, -80 0/0 80/0 -80/80 0`
  - **Focus floating/tiled**: `CTRL ALT, up/down, exec, hyprctl dispatch focuswindow floating/tiled`
  - **Power menu**: `$mod SHIFT, Escape, exec, power-menu`
  - **Lock via Escape**: `$mod, Escape, exec, ${pkgs.swaylock-effects}/bin/swaylock`
  - **Hyprlock alt**: `ALT, Escape, exec, hyprlock`
  - **movetoworkspacesilent** instead of movetoworkspace for SHIFT+1-0 (old used silent variant)
  - **XF86AudioStop**: `, XF86AudioStop, exec, ${pkgs.playerctl}/bin/playerctl stop`
- All executables MUST use full nix store paths (`${pkgs.xxx}/bin/xxx`)

### 4. Restore Missing Hyprland Window Rules
- **Task ID**: hyprland-windowrules
- **Depends On**: none
- **Assigned To**: builder-hyprland
- **Agent Type**: general-purpose
- **Parallel**: true
- Read old `~/Development/moshpitcodes.nix-main/modules/home/hyprland/config.nix` windowrule section (lines 292-358)
- Add missing window rules to `modules/home/hyprland/default.nix`:
  - **Workspace assignments**:
    - `workspace 3, match:class ^(evince)$`
    - `workspace 4, match:class ^(Gimp-2.10)$`
    - `workspace 5, match:class ^(Audacious)$`
    - `workspace 5, match:class ^(Spotify)$`
    - `workspace 8, match:class ^(com.obsproject.Studio)$`
    - `workspace 10, match:class ^(discord)$`
  - **Float rules**:
    - `float on, match:class ^(Viewnior)$`
    - `float on, match:class ^(imv)$`
    - `float on, match:class ^(mpv)$`
    - `float on, match:class ^(Audacious)$`
    - `float on, match:class ^(zenity)$`
    - `size 850 500, match:class ^(zenity)$`
    - `float on, match:class ^(org.gnome.FileRoller)$`
    - `float on, match:class ^(SoundWireServer)$`
    - `size 725 330, match:class ^(SoundWireServer)$`
    - `float on, match:title ^(Volume Control)$`
    - `size 700 450, match:title ^(Volume Control)$`
  - **xwaylandvideobridge rules** (for OBS screen capture):
    - `opacity 0.0 0.0, match:class ^(xwaylandvideobridge)$`
    - `no_anim on, match:class ^(xwaylandvideobridge)$`
    - `no_initial_focus on, match:class ^(xwaylandvideobridge)$`
    - `max_size 1 1, match:class ^(xwaylandvideobridge)$`
    - `no_blur on, match:class ^(xwaylandvideobridge)$`

### 5. Add Missing Hyprland Lid Switch + xwayland Config
- **Task ID**: hyprland-extra
- **Depends On**: none
- **Assigned To**: builder-hyprland
- **Agent Type**: general-purpose
- **Parallel**: true
- Read old `~/Development/moshpitcodes.nix-main/modules/home/hyprland/config.nix` (lines 274-386)
- Add to `modules/home/hyprland/laptop-overrides.nix`:
  - `bindl` section for lid switch events (conditional on laptop host)
  - xwayland force_zero_scaling setting
- Add to `modules/home/hyprland/default.nix`:
  - `xwayland { force_zero_scaling = true; }` in extraConfig or settings

### 6. Restore Missing Development Tools
- **Task ID**: devtools-restore
- **Depends On**: none
- **Assigned To**: builder-devtools
- **Agent Type**: general-purpose
- **Parallel**: true
- Read old `~/Development/moshpitcodes.nix-main/modules/home/development/development.nix`
- Add missing packages to `modules/home/development/development.nix`:
  - **Terraform/IaC**: `terraform`, `terraform-docs`, `terraform-ls`, `tflint`, `tfsec`, `ansible`
  - **Kubernetes**: `kubectl`, `kubernetes-helm`, `k9s`, `kubectx`, `talosctl`, `cilium-cli`
  - **Cloud**: `azure-cli`
  - **Go tools**: `go-migrate`, `gopls`, `golangci-lint`, `gofumpt` (check if already in language-servers.nix first)
  - **Protobuf**: `grpc`, `protobuf`, `protoc-gen-go`, `protoc-gen-go-grpc`
  - **Java**: `maven`, `gradle` (check versions — old had `gradle_9`)
  - **Database**: `sqlc`, `postgresql`
  - **Nix tools**: `nix-prefetch-github`, `nix-output-monitor`, `nvd`
  - **Container**: `docker-compose`
  - **API testing**: `bruno`
- Check `modules/home/language-servers.nix` first to avoid duplicates
- All packages must use `pkgs.xxx` format

### 7. Restore Missing Zsh Aliases
- **Task ID**: zsh-aliases
- **Depends On**: none
- **Assigned To**: builder-zsh
- **Agent Type**: general-purpose
- **Parallel**: true
- Read old `~/Development/moshpitcodes.nix-main/modules/home/zsh/zsh_alias.nix`
- Add missing aliases to `modules/home/zsh/default.nix` shellAliases section:
  - `c = "clear"`, `cd = "z"`, `tt = "gtrash put"`, `nano = "micro"`
  - `diff = "delta --diff-so-fancy --side-by-side"`, `less = "bat"`, `y = "yazi"`
  - `py = "python"`, `icat = "viu"`, `dsize = "du -hs"`, `pdf = "tdf"`, `open = "xdg-open"`, `space = "ncdu"`
  - `l = "eza --icons -a --group-directories-first -1"`
  - `ll = "eza --icons -a --group-directories-first -1 --long --no-user"`
  - `tree = "eza --icons --tree --group-directories-first"`
  - NixOS management: `cdnix`, `ns` (nixos-rebuild switch), `nd` (nix develop), `nb` (nix build), `nfu` (nix flake update), `hms` (home-manager switch)
  - Backup aliases: `backup-repos-now`, `backup-repos-status`, `backup-repos-logs`, `backup-repos-timer`
- Update alias paths to use `${pkgs.xxx}/bin/xxx` format where referencing nix packages
- Adapt `cdnix` path from `~/Development/moshpitcodes.nix` to `~/Development/shifttab.nix`

### 8. Restore Zsh FZF-Tab and Init Logic
- **Task ID**: zsh-fzftab
- **Depends On**: none
- **Assigned To**: builder-zsh
- **Agent Type**: general-purpose
- **Parallel**: true
- Read old `~/Development/moshpitcodes.nix-main/modules/home/zsh/zsh.nix` (lines 15-96 for FZF-Tab, lines 132-207 for init logic)
- Add to `modules/home/zsh/default.nix`:
  - FZF-Tab plugin (via `programs.zsh.plugins` or `zsh-fzf-tab` package)
  - FZF completion styles (preview commands for files, directories, processes, git)
  - GPG TTY setup: `export GPG_TTY=$(tty)` and `gpg-connect-agent updatestartuptty /bye`
  - SSH key auto-load from `~/.ssh/` for `id_ed25519` and `id_rsa`
  - Terminal mode handling for proper cursor shape (beam for insert, block for normal)
- Do NOT add WSL-specific fixes unless building for WSL host

### 9. Restore Missing Packages
- **Task ID**: packages-restore
- **Depends On**: none
- **Assigned To**: builder-packages
- **Agent Type**: general-purpose
- **Parallel**: true
- Add to `modules/home/packages.nix`:
  - `mimeo` — MIME type file opener
- Verify `wineWow64Packages.wayland` is correct (old had `wineWowPackages.wayland`)
- Check if `reposync` is available as an overlay or custom package (it was in old via overlay)

### 10. Final Build Validation
- **Task ID**: validate-all
- **Depends On**: hyprland-autostart, hyprland-misc, hyprland-keybinds, hyprland-windowrules, hyprland-extra, devtools-restore, zsh-aliases, zsh-fzftab, packages-restore
- **Assigned To**: validator
- **Agent Type**: general-purpose
- **Parallel**: false
- Run: `nix build .#nixosConfigurations.vmware-guest.config.system.build.toplevel --impure --no-link`
- Run: `nix build .#nixosConfigurations.laptop.config.system.build.toplevel --impure --no-link`
- Verify zero build errors
- Check for evaluation warnings that need addressing

## Acceptance Criteria
- Both `vmware-guest` and `laptop` configurations build successfully with zero errors
- All missing Hyprland keybinds from old config are present (hjkl navigation, power menu, lock, etc.)
- All missing window rules restored (workspace assignments, float rules, xwaylandvideobridge)
- Development tools restored (terraform, kubernetes, go tooling, protobuf, etc.)
- Zsh aliases restored (NixOS management, convenience aliases, FZF-Tab plugin)
- Autostart services restored (easyeffects, poweralertd, cursor init)
- Misc Hyprland settings restored (numlock, repeat_delay, enable_swallow, etc.)

## Validation Commands
- `nix build .#nixosConfigurations.vmware-guest.config.system.build.toplevel --impure --no-link` — Build vmware-guest
- `nix build .#nixosConfigurations.laptop.config.system.build.toplevel --impure --no-link` — Build laptop

## Notes
- All executables in Hyprland/waybar configs MUST use full nix store paths `${pkgs.xxx}/bin/xxx`
- German keyboard layout: `kb_layout = "de"` must be preserved
- Do NOT replace walker with rofi, nautilus with nemo, or Everforest with Rose Pine — these are intentional changes
- The `movetoworkspacesilent` variant (old config) moves windows without switching focus — consider whether the current `movetoworkspace` behavior is preferred
- `reposync` was a custom package in the old config overlay — check if it needs to be packaged in `pkgs/` or overlays
- The old config had `dbus-update-activation-environment` in autostart — this is handled by UWSM in the current config, so it should NOT be re-added
