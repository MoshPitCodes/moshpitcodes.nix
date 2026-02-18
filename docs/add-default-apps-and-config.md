# Plan: Add Default Apps, CLIs, and Options

## Task Description
Expand the current minimal VMware guest NixOS configuration to include the full set of default applications, CLI tools, desktop environment polish, development environment tooling, and system infrastructure that a complete daily-driver NixOS + Hyprland setup requires. The current config has basic scaffolding but is missing many essential programs, desktop integration features, and development tools.

## Objective
When complete, the VMware guest configuration will be a fully-featured Hyprland desktop with:
- Comprehensive CLI toolkit with modern replacements
- Polished desktop environment (screen locking, idle management, wallpaper, theming, clipboard)
- Essential desktop applications (browser, media, file management)
- Development environment with Docker, language toolchains, and editor config
- System infrastructure (treefmt, utility scripts)

## Problem Statement
The current configuration only has the bare minimum to boot into Hyprland with a terminal and launcher. It lacks screen locking, wallpaper, theming, browser, development toolchains, Docker, and many standard CLI tools expected in a productive NixOS environment. This means the system is not usable as a daily driver for development work.

## Solution Approach
Add the missing pieces as modular NixOS/Home Manager modules following the existing patterns:
- Each logical group becomes a new `.nix` module or extends an existing one
- Full nix store paths used in Hyprland exec-once/bind commands (proven pattern from earlier fixes)
- All packages installed via declarative config, no imperative installs
- VM-appropriate defaults (no Bluetooth, reduced animations already handled)

## Relevant Files
Use these files to complete the task:

- `modules/home/packages.nix` - Main user packages list, needs many additions
- `modules/home/hyprland/default.nix` - Hyprland config, needs screen lock/idle/wallpaper/clipboard integration
- `modules/home/hyprland/vm-overrides.nix` - VM-specific Hyprland overrides
- `modules/home/zsh/default.nix` - Shell config, may need additional aliases
- `modules/home/default.nix` - Home module aggregator, needs new module imports
- `modules/home/waybar/default.nix` - Waybar config, may need additional modules
- `modules/core/default.nix` - Core module aggregator, needs new module imports
- `modules/core/system.nix` - System config, may need locale/font additions
- `hosts/vmware-guest/default.nix` - Host config, may need Docker/services
- `flake.nix` - May need treefmt integration updates

### New Files
- `modules/home/hyprlock.nix` - Screen locking configuration
- `modules/home/hypridle.nix` - Idle management configuration
- `modules/home/theming.nix` - GTK/Qt/cursor theming
- `modules/home/browser.nix` - Firefox configuration
- `modules/home/media.nix` - Media/image/PDF viewers
- `modules/home/tmux.nix` - Terminal multiplexer config
- `modules/core/docker.nix` - Docker/container runtime
- `modules/core/fonts.nix` - System-wide font configuration
- `treefmt.toml` - Code formatting configuration

## Implementation Phases
### Phase 1: Foundation
System-level additions (Docker, fonts, treefmt) and CLI tool expansion that other phases depend on.

### Phase 2: Core Implementation
Desktop environment polish (locking, idle, wallpaper, theming, clipboard) and desktop applications (browser, media).

### Phase 3: Integration & Polish
Development environment tooling, shell enhancements, and final validation that everything builds and works together.

## Team Orchestration

- You operate as the team lead and orchestrate the team to execute the plan.
- You're responsible for deploying the right team members with the right context to execute the plan.
- IMPORTANT: You NEVER operate directly on the codebase. You use `Task` and `Task*` tools to deploy team members to do the building, validating, testing, deploying, and other tasks.
- Take note of the session id of each team member. This is how you'll reference them.

### Team Members

- Builder
  - Name: engineer-cli-shell
  - Role: Implement CLI tools expansion and shell enhancements (packages.nix, tmux, zsh aliases)
  - Agent Type: nixos
  - Resume: true

- Builder
  - Name: validator-cli-shell
  - Role: Validate CLI tools and shell enhancements build correctly and follow NixOS conventions
  - Agent Type: nixos
  - Resume: true

- Builder
  - Name: engineer-desktop-env
  - Role: Implement desktop environment polish (hyprlock, hypridle, theming, clipboard, wallpaper)
  - Agent Type: nixos
  - Resume: true

- Builder
  - Name: validator-desktop-env
  - Role: Validate desktop environment modules build correctly and integrate with Hyprland
  - Agent Type: nixos
  - Resume: true

- Builder
  - Name: engineer-apps
  - Role: Implement desktop applications (browser, media viewers) and development environment (Docker, dev tools)
  - Agent Type: nixos
  - Resume: true

- Builder
  - Name: validator-apps
  - Role: Validate desktop apps and dev environment modules build correctly
  - Agent Type: nixos
  - Resume: true

- Builder
  - Name: engineer-infra
  - Role: Implement system infrastructure (fonts, Docker, treefmt, system services)
  - Agent Type: nixos
  - Resume: true

- Builder
  - Name: validator-infra
  - Role: Validate system infrastructure modules, run treefmt, verify full system build
  - Agent Type: nixos
  - Resume: true

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

### 1. Expand CLI Tools & Add Tmux
- **Task ID**: cli-tools-expansion
- **Depends On**: none
- **Assigned To**: engineer-cli-shell
- **Agent Type**: nixos
- **Parallel**: true
- Add modern CLI tools to `modules/home/packages.nix`:
  - `lazygit` - TUI git client
  - `tokei` - code statistics
  - `dust` - disk usage analyzer (du replacement)
  - `duf` - disk free utility (df replacement)
  - `procs` - process viewer (ps replacement)
  - `bottom` - system monitor (btm)
  - `tealdeer` - tldr pages client
  - `zoxide` - smarter cd
  - `yazi` - terminal file manager
  - `httpie` - HTTP client
  - `dogdns` - DNS client (dig replacement)
  - `sd` - sed alternative
  - `choose` - cut alternative
  - `hyperfine` - benchmarking tool
  - `glow` - markdown viewer
  - `nix-tree` - nix dependency viewer
  - `nix-diff` - nix derivation diff tool
  - `comma` - run commands from nix packages without installing
- Create `modules/home/tmux.nix` with:
  - Tmux enabled via `programs.tmux`
  - Vi-mode keybindings
  - Sensible defaults (mouse support, 256 colors, history 10000)
  - Status bar with gruvbox colors
  - Prefix key set to `Ctrl+a`
- Import tmux.nix in `modules/home/default.nix`
- Enable zoxide integration in zsh config (`programs.zoxide.enable = true; programs.zoxide.enableZshIntegration = true;`)

### 2. Validate CLI Tools & Tmux
- **Task ID**: validate-cli-tools
- **Depends On**: cli-tools-expansion
- **Assigned To**: validator-cli-shell
- **Agent Type**: nixos
- **Parallel**: false
- Verify `nix build .#nixosConfigurations.vmware-guest.config.system.build.toplevel` succeeds
- Verify all new packages resolve to valid derivations
- Verify tmux.nix follows existing module patterns (function signature, structure)
- Verify no duplicate packages between packages.nix and other modules
- Verify zoxide integration is correctly placed in zsh config

### 3. Add System Infrastructure (Fonts, Docker, Treefmt)
- **Task ID**: system-infra
- **Depends On**: none
- **Assigned To**: engineer-infra
- **Agent Type**: nixos
- **Parallel**: true (parallel with task 1)
- Create `modules/core/fonts.nix`:
  - System-level font packages: `noto-fonts`, `noto-fonts-cjk-sans`, `noto-fonts-emoji`, `liberation_ttf`, `font-awesome`
  - Font configuration with default fonts for serif/sans-serif/monospace
- Create `modules/core/docker.nix`:
  - `virtualisation.docker.enable = true`
  - `virtualisation.docker.autoPrune.enable = true`
  - Docker compose included (`docker-compose` package or built-in)
  - Note: user already in `docker` group in user.nix
- Create `treefmt.toml` in project root:
  - Configure `nixfmt` formatter for `*.nix` files
  - Configure `shfmt` for `*.sh` files
- Import fonts.nix and docker.nix in `modules/core/default.nix`

### 4. Validate System Infrastructure
- **Task ID**: validate-system-infra
- **Depends On**: system-infra
- **Assigned To**: validator-infra
- **Agent Type**: nixos
- **Parallel**: false
- Verify `nix build .#nixosConfigurations.vmware-guest.config.system.build.toplevel` succeeds
- Verify fonts.nix and docker.nix follow existing module patterns
- Verify treefmt.toml is valid (`nix develop -c treefmt --check` or parse validation)
- Verify docker group assignment is not duplicated
- Verify font configuration doesn't conflict with home-manager font packages

### 5. Add Desktop Environment Polish (Hyprlock, Hypridle, Theming, Clipboard)
- **Task ID**: desktop-polish
- **Depends On**: none
- **Assigned To**: engineer-desktop-env
- **Agent Type**: nixos
- **Parallel**: true (parallel with tasks 1 and 3)
- Create `modules/home/hyprlock.nix`:
  - `programs.hyprlock.enable = true`
  - Gruvbox-themed lock screen with clock and input field
  - Background blur or solid dark color
- Create `modules/home/hypridle.nix`:
  - `services.hypridle.enable = true`
  - Lock screen after 5 minutes of inactivity
  - Turn off display after 10 minutes
  - Use full path to hyprlock binary
- Create `modules/home/theming.nix`:
  - GTK theme: Adwaita-dark or Gruvbox-Dark via `gtk.enable`, `gtk.theme`
  - Icon theme: Papirus-Dark
  - Cursor theme: Bibata-Modern-Classic
  - Qt integration via `qt.enable`, `qt.platformTheme`, `qt.style`
  - Cursor size 24
  - Required packages: `papirus-icon-theme`, `bibata-cursors`
- Add clipboard manager to Hyprland config:
  - Add `cliphist` to packages
  - Add `wl-paste --type text --watch cliphist store` to exec-once
  - Add `wl-paste --type image --watch cliphist store` to exec-once
  - Add keybind `$mod, C, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy`
- Add hyprlock keybind to Hyprland: `$mod, L, exec, hyprlock`
- Import hyprlock.nix, hypridle.nix, theming.nix in `modules/home/default.nix`

### 6. Validate Desktop Environment Polish
- **Task ID**: validate-desktop-polish
- **Depends On**: desktop-polish
- **Assigned To**: validator-desktop-env
- **Agent Type**: nixos
- **Parallel**: false
- Verify `nix build .#nixosConfigurations.vmware-guest.config.system.build.toplevel` succeeds
- Verify hyprlock, hypridle, theming modules follow existing patterns
- Verify Hyprland keybinds use full nix store paths for cliphist, hyprlock
- Verify no conflicting cursor/theme settings between modules
- Verify hypridle correctly references hyprlock binary path
- Verify clipboard exec-once commands use full paths

### 7. Add Desktop Applications (Browser, Media)
- **Task ID**: desktop-apps
- **Depends On**: none
- **Assigned To**: engineer-apps
- **Agent Type**: nixos
- **Parallel**: true (parallel with tasks 1, 3, 5)
- Create `modules/home/browser.nix`:
  - `programs.firefox.enable = true`
  - Enable Wayland: `programs.firefox.nativeMessagingHosts` or environment variable
  - Basic settings for privacy/performance
- Create `modules/home/media.nix`:
  - `mpv` for video playback (with `programs.mpv.enable` if available, otherwise package)
  - `imv` for image viewing (Wayland-native)
  - `zathura` for PDF viewing (`programs.zathura.enable = true`, gruvbox theme)
  - `obs-studio` for screen recording (optional, add as package)
- Import browser.nix and media.nix in `modules/home/default.nix`

### 8. Validate Desktop Applications
- **Task ID**: validate-desktop-apps
- **Depends On**: desktop-apps
- **Assigned To**: validator-apps
- **Agent Type**: nixos
- **Parallel**: false
- Verify `nix build .#nixosConfigurations.vmware-guest.config.system.build.toplevel` succeeds
- Verify Firefox is configured for Wayland
- Verify media.nix follows module patterns
- Verify no package conflicts or duplicates
- Verify zathura theme configuration is valid

### 9. Full System Integration Build
- **Task ID**: full-integration
- **Depends On**: validate-cli-tools, validate-system-infra, validate-desktop-polish, validate-desktop-apps
- **Assigned To**: validator-infra
- **Agent Type**: nixos
- **Parallel**: false
- Run full system build: `nix build .#nixosConfigurations.vmware-guest.config.system.build.toplevel`
- Verify no evaluation warnings from our modules (xorg warnings from Hyprland are acceptable)
- Verify all new module imports are correctly added to aggregator files
- Verify no circular dependencies between modules
- Verify flake check passes: `nix flake check`
- Run formatter if treefmt.toml exists: `nix develop -c treefmt`
- List all new files created and confirm they match the plan

## Acceptance Criteria
- All new modules follow the existing pattern: `{ pkgs, ... }: { ... }`
- `nix build .#nixosConfigurations.vmware-guest.config.system.build.toplevel` succeeds with no errors
- `nix flake check` passes
- No duplicate package declarations across modules
- All Hyprland exec-once and bind commands use full nix store paths (`${pkgs.foo}/bin/foo`)
- All new modules imported in their respective `default.nix` aggregators
- Gruvbox Dark theme consistently applied across hyprlock, zathura, tmux, waybar
- Screen locking works: keybind ($mod+L) and auto-lock via hypridle
- Docker service is enabled and accessible
- Firefox is configured for Wayland
- treefmt.toml is present and valid
- Keyboard layout remains `de` throughout all configurations

## Validation Commands
Execute these commands to validate the task is complete:

- `nix build .#nixosConfigurations.vmware-guest.config.system.build.toplevel --no-link` - Full system build succeeds
- `nix flake check` - Flake evaluation passes
- `nix eval .#nixosConfigurations.vmware-guest.config.system.build.toplevel --raw 2>&1 | head -5` - Quick eval check
- `grep -r "import" modules/home/default.nix` - Verify all new home modules imported
- `grep -r "import" modules/core/default.nix` - Verify all new core modules imported

## Notes
- All packages come from nixpkgs unstable (already configured in flake.nix)
- The VM-overrides pattern (`modules/home/hyprland/vm-overrides.nix`, `modules/core/vm-overrides.nix`) should be respected - don't add features that conflict with VM usage
- `default.vm.nix` exists in home modules but is not currently referenced in flake.nix - the flake imports `modules/home` directly. Keep using that pattern.
- The `security.pam.services.hyprlock` entry already exists in `modules/core/security.nix`, so hyprlock PAM is already configured
- `neofetch` is deprecated in recent nixpkgs - consider replacing with `fastfetch` in the CLI tools expansion
- Keep foot terminal as a fallback even though ghostty is the primary terminal
