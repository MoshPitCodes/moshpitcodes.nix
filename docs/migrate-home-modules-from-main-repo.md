# Plan: Migrate Home Modules from moshpitcodes.nix Main Repo

## Task Description

Bring over all missing modules from `https://github.com/MoshPitCodes/moshpitcodes.nix/tree/main/modules/home` into the local `shifttab.nix` project. This includes new application configs, development toolchains, shell integrations, security modules, media apps, and host-specific variants (WSL). Restructure where necessary to fit the local project's conventions (Everforest theme, walker instead of rofi, hyprpaper instead of waypaper, hyprlock instead of swaylock, starship instead of oh-my-posh). Also bring over missing `modules/core` modules needed as dependencies.

## Objective

When complete, the local `shifttab.nix` project will have feature parity with the main `moshpitcodes.nix` repo's home modules, properly themed with Everforest colors, structured for multi-host support (vmware-guest, desktop, laptop, WSL), and building successfully.

## Problem Statement

The local project is missing ~35 home modules and ~6 core modules that exist in the main repo. This includes critical infrastructure (SSH key management, GPG, dconf, development toolchains), useful desktop apps (VS Code, Discord, Obsidian), CLI tool configs (bat, fzf, yazi, lazygit with proper theming), and host-specific variants (WSL support). Without these, the system is incomplete for daily use across multiple hosts.

## Solution Approach

1. **Group modules by dependency and theme complexity** into 8 work streams
2. **Bring core modules first** (program.nix, hardware.nix, etc.) as they're dependencies
3. **Adapt themed modules** from Rose Pine → Everforest color palette
4. **Add missing flake inputs** required by new modules (spicetify-nix, yazi-plugins, etc.)
5. **Update aggregator files** (default.nix, default.vm.nix, default.wsl.nix)
6. **Validate** with `nix build` after each task group

## Relevant Files

### Source (GitHub repo - read-only reference)
- `https://github.com/MoshPitCodes/moshpitcodes.nix/tree/main/modules/home` - All 51 files/dirs
- `https://github.com/MoshPitCodes/moshpitcodes.nix/tree/main/modules/core` - Core module deps
- `https://github.com/MoshPitCodes/moshpitcodes.nix/blob/main/flake.nix` - Flake inputs reference

### Local files to modify
- `flake.nix` - Add new inputs (spicetify-nix, yazi-plugins, sidecar, td, nix-flatpak, nixos-wsl)
- `modules/home/default.nix` - Add new imports
- `modules/home/default.vm.nix` - VM-specific import list
- `modules/home/packages.nix` - Merge missing packages
- `modules/core/default.nix` - Add new core imports

### New Files to Create

**Core modules:**
- `modules/core/program.nix` - dconf, zsh enable, GPG agent, nix-ld
- `modules/core/hardware.nix` - Graphics, firmware, bluetooth (for future hosts)
- `modules/core/xserver.nix` - X keyboard, libinput, shutdown timeout
- `modules/core/virtualization.nix` - libvirt, Docker, SPICE (replaces docker.nix)
- `modules/core/samba.nix` - CIFS/SMB NAS mounts
- `modules/core/steam.nix` - Steam + Gamescope
- `modules/core/flatpak.nix` - Flatpak + Wayland
- `modules/core/default.wsl.nix` - WSL core imports
- `modules/core/wsl-overrides.nix` - WSL force-disables

**Home modules (new):**
- `modules/home/bat.nix` - bat with Everforest theme
- `modules/home/fzf.nix` - fzf with fd/bat/eza integration, Everforest colors
- `modules/home/lazygit.nix` - lazygit with Everforest theme (replace package-only)
- `modules/home/vivid.nix` - LS_COLORS + eza colors, Everforest palette
- `modules/home/yazi.nix` - yazi with full config (replace package-only)
- `modules/home/cava.nix` - audio visualizer, Everforest gradient
- `modules/home/micro.nix` - micro editor, Everforest theme
- `modules/home/openssh.nix` - SSH client, key management, GitHub known_hosts
- `modules/home/gpg.nix` - GPG key management
- `modules/home/gnome.nix` - evince, file-roller, gnome-keyring
- `modules/home/xdg-mimes.nix` - MIME type associations
- `modules/home/obsidian.nix` - Obsidian notes
- `modules/home/vscode.nix` - VS Code + settings
- `modules/home/vscode-extensions.nix` - VS Code extensions
- `modules/home/discord/default.nix` - Discord with theme
- `modules/home/audacious.nix` - Audacious music player
- `modules/home/spicetify.nix` - Spotify via spicetify
- `modules/home/gaming.nix` - CLI games
- `modules/home/backup-repos.nix` - Automated NAS backups
- `modules/home/scripts/` - Custom shell scripts
- `modules/home/development/default.nix` - Dev aggregator
- `modules/home/development/development.nix` - Dev toolchains
- `modules/home/development/claude-code.nix` - Claude Code config
- `modules/home/development/opencode.nix` - OpenCode + MCP
- `modules/home/development/sidecar.nix` - TD sidecar
- `modules/home/viewnior.nix` - Image viewer
- `modules/home/default.wsl.nix` - WSL home imports
- `modules/home/fonts-wsl.nix` - WSL font config
- `modules/home/keyring-wsl.nix` - WSL keyring

## Implementation Phases

### Phase 1: Foundation
- Add missing flake inputs
- Bring over core module dependencies (program.nix, hardware.nix, xserver.nix, virtualization.nix)
- Update core/default.nix imports

### Phase 2: Core Implementation
- Migrate shell & CLI tool configs (bat, fzf, lazygit, vivid, yazi) with Everforest theming
- Migrate security modules (openssh, gpg)
- Migrate desktop apps (gnome, xdg-mimes, obsidian, vscode, discord)
- Migrate media/entertainment (audacious, cava, spicetify, gaming)
- Migrate development environment (development/, backup-repos, scripts)
- Merge packages.nix additions

### Phase 3: Integration & Polish
- Create WSL host support files
- Update all aggregator files (default.nix, default.vm.nix, default.wsl.nix)
- Full build validation across all host configs
- Verify no 3-byte Nerd Font icons in new modules (nixfmt stripping issue)

## Team Orchestration

- I operate as team lead and orchestrate the team to execute the plan.
- I NEVER operate directly on the codebase. I use `Task` and `Task*` tools to deploy team members.
- Each task gets exactly 1 staff engineer (builder) + 1 validator as requested.
- Staff engineers use the `nixos` agent type for NixOS-specific work.
- Validators use the `validator` agent type for review.

### Team Members

- Builder
  - Name: `nix-core-engineer`
  - Role: Migrate core NixOS modules and flake inputs
  - Agent Type: `nixos`
  - Resume: true

- Builder
  - Name: `nix-shell-tools-engineer`
  - Role: Migrate shell/CLI tool configs with Everforest theming
  - Agent Type: `nixos`
  - Resume: true

- Builder
  - Name: `nix-security-engineer`
  - Role: Migrate openssh, gpg, gnome-keyring modules
  - Agent Type: `nixos`
  - Resume: true

- Builder
  - Name: `nix-desktop-apps-engineer`
  - Role: Migrate desktop apps (vscode, discord, obsidian, xdg-mimes, gnome)
  - Agent Type: `nixos`
  - Resume: true

- Builder
  - Name: `nix-media-engineer`
  - Role: Migrate media/entertainment modules (audacious, cava, spicetify, gaming)
  - Agent Type: `nixos`
  - Resume: true

- Builder
  - Name: `nix-dev-env-engineer`
  - Role: Migrate development/ directory, backup-repos, scripts, packages merge
  - Agent Type: `nixos`
  - Resume: true

- Builder
  - Name: `nix-wsl-engineer`
  - Role: Create WSL host support files and aggregator updates
  - Agent Type: `nixos`
  - Resume: true

- Builder
  - Name: `nix-integration-engineer`
  - Role: Final integration - update all default.nix aggregators, fix imports, build validation
  - Agent Type: `nixos`
  - Resume: true

- Validator (shared across tasks)
  - Name: `nix-validator`
  - Role: Validate each task's output for correctness, Everforest theming, build success
  - Agent Type: `validator`
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

### 1. Add Flake Inputs & Core Modules
- **Task ID**: `flake-inputs-and-core-modules`
- **Depends On**: none
- **Assigned To**: `nix-core-engineer` + `nix-validator`
- **Agent Type**: `nixos` / `validator`
- **Parallel**: false (foundation - everything depends on this)
- Add these flake inputs to `flake.nix`:
  - `spicetify-nix` = `github:gerg-l/spicetify-nix`
  - `nix-flatpak` = `github:gmodena/nix-flatpak`
  - `yazi-plugins` = `github:yazi-rs/plugins`
  - `sidecar` = `github:marcus/sidecar`
  - `td` = `github:marcus/td`
  - `nixos-wsl` = `github:nix-community/NixOS-WSL` (for future WSL host)
- Fetch and create these core modules from GitHub repo (adapt as needed):
  - `modules/core/program.nix` - dconf.enable, programs.zsh.enable, gnupg agent, nix-ld
  - `modules/core/hardware.nix` - Intel graphics, enableRedistributableFirmware, bluetooth
  - `modules/core/xserver.nix` - German keyboard, libinput, DefaultTimeoutStopSec=10s
  - `modules/core/virtualization.nix` - libvirt, Docker, SPICE (replaces existing docker.nix)
  - `modules/core/samba.nix` - CIFS/SMB NAS mounts with secrets
  - `modules/core/steam.nix` - Steam + Gamescope + Proton GE
  - `modules/core/flatpak.nix` - Flatpak + Wayland forcing
- Delete `modules/core/docker.nix` (superseded by virtualization.nix)
- Update `modules/core/default.nix` to import new modules (remove docker.nix, add new ones)
- Pass new inputs through `specialArgs` and `extraSpecialArgs` in flake.nix
- Run `nix build .#nixosConfigurations.vmware-guest.config.system.build.toplevel`
- **IMPORTANT**: Core modules like steam.nix, samba.nix, flatpak.nix should NOT be imported in the vmware-guest default.nix yet - they're for future hosts. Only import program.nix, hardware.nix, xserver.nix, virtualization.nix in core/default.nix
- **IMPORTANT**: The vmware-guest host config already sets `virtualisation.vmware.guest.enable = true` and its own graphics settings. `hardware.nix` and `virtualization.nix` should use `lib.mkDefault` for settings that the host may override, or be conditionally imported

### 2. Shell & CLI Tool Configs
- **Task ID**: `shell-cli-tool-configs`
- **Depends On**: `flake-inputs-and-core-modules`
- **Assigned To**: `nix-shell-tools-engineer` + `nix-validator`
- **Agent Type**: `nixos` / `validator`
- **Parallel**: true (can run alongside tasks 3-6)
- Fetch from GitHub and create with Everforest theming:
  - `modules/home/bat.nix` - bat + batman, batpipe. Theme: Everforest (not rose-pine). Use `programs.bat` Home Manager module
  - `modules/home/fzf.nix` - fzf with fd default command, eza tree preview, bat file preview. Everforest colors for fzf UI (bg: `#2d353b`, fg: `#d3c6aa`, hl: `#a7c080`, selected: `#dbbc7f`, info: `#7fbbb3`, pointer: `#e67e80`)
  - `modules/home/vivid.nix` - LS_COLORS via vivid + eza color theme. Map Rose Pine palette to Everforest: foam→`#83c092`, gold→`#dbbc7f`, love→`#e67e80`, muted→`#859289`, subtle→`#9da9a0`, iris→`#7fbbb3`
  - `modules/home/yazi.nix` - yazi with full config from GitHub (full-border plugin, settings). Needs `yazi-plugins` flake input. Remove yazi from packages.nix (now has own module)
  - `modules/home/lazygit.nix` - lazygit with Everforest theme. Map rose-pine colors to Everforest. Remove lazygit from packages.nix (now has own module)
- Remove `bat`, `fzf`, `lazygit`, `yazi` from `packages.nix` (they now have dedicated modules)
- **Everforest color reference** for theming:
  - Background: `#2d353b`, Foreground: `#d3c6aa`
  - Surface: `#3d484d`, Border: `#475258`
  - Red: `#e67e80`, Green: `#a7c080`, Yellow: `#dbbc7f`
  - Blue: `#7fbbb3`, Aqua: `#83c092`, Purple: `#d699b6`
  - Grey: `#859289`, Light grey: `#9da9a0`
- **IMPORTANT**: Any Nerd Font icons in these files must use 4-byte MDI codepoints (U+F0000+), NOT 3-byte BMP PUA (U+E000-U+F8FF), because nixfmt strips 3-byte PUA characters

### 3. Security & System Integration
- **Task ID**: `security-system-integration`
- **Depends On**: `flake-inputs-and-core-modules`
- **Assigned To**: `nix-security-engineer` + `nix-validator`
- **Agent Type**: `nixos` / `validator`
- **Parallel**: true
- Fetch from GitHub and create:
  - `modules/home/openssh.nix` - SSH key management with:
    - SSH key provisioning from secrets
    - GitHub known_hosts pre-seeding (prevents interactive prompts)
    - Per-host match blocks for GitHub and wildcard
    - AddKeysToAgent for all hosts
    - Uses `customsecrets` for key paths
  - `modules/home/gpg.nix` - GPG configuration:
    - Key import/trust from secrets
    - Integration with gnome-keyring
  - `modules/home/gnome.nix` - GNOME utilities:
    - evince (PDF viewer)
    - file-roller (archive manager)
    - gnome-text-editor
    - gnome-keyring with PAM integration
  - `modules/home/xdg-mimes.nix` - MIME type associations:
    - Map all file types to appropriate apps
    - Use local app names: firefox for browser, nautilus for directories, ghostty for terminal
    - Adapt from GitHub (which uses nemo/viewnior) to local apps (nautilus/imv)

### 4. Desktop Applications
- **Task ID**: `desktop-applications`
- **Depends On**: `flake-inputs-and-core-modules`
- **Assigned To**: `nix-desktop-apps-engineer` + `nix-validator`
- **Agent Type**: `nixos` / `validator`
- **Parallel**: true
- Fetch from GitHub and create:
  - `modules/home/obsidian.nix` - Simple package install
  - `modules/home/vscode.nix` - VS Code with settings. Adapt from GitHub:
    - Keep language server configs (Go, Nix, Zig, C/C++)
    - Use Everforest theme extension instead of rose-pine
    - Use FiraCode Nerd Font for editor font
  - `modules/home/vscode-extensions.nix` - Extension list from GitHub
  - `modules/home/discord/default.nix` - Discord with custom CSS. Note: GitHub uses a directory with theme files - bring over the structure
  - `modules/home/viewnior.nix` - Image viewer package
  - `modules/home/micro.nix` - micro editor with Everforest theme:
    - Create custom colorscheme mapping rose-pine → Everforest
    - default fg: `#d3c6aa`, comment: `#859289`, string: `#a7c080`, keyword: `#e67e80`, identifier: `#83c092`

### 5. Media & Entertainment
- **Task ID**: `media-entertainment`
- **Depends On**: `flake-inputs-and-core-modules`
- **Assigned To**: `nix-media-engineer` + `nix-validator`
- **Agent Type**: `nixos` / `validator`
- **Parallel**: true
- Fetch from GitHub and create:
  - `modules/home/audacious.nix` - Audacious music player with dark theme
  - `modules/home/cava.nix` - Audio visualizer with Everforest gradient:
    - Original rose-pine gradient: cyan → purple → rose → peach → pink
    - Everforest gradient: `#83c092` → `#7fbbb3` → `#a7c080` → `#dbbc7f` → `#e67e80`
  - `modules/home/spicetify.nix` - Spotify customization via spicetify-nix:
    - Needs `spicetify-nix` flake input
    - Extensions: adblock, hidePodcasts, shuffle+
    - Theme: Use Everforest-compatible theme (dribbblish with custom colors or catppuccin)
  - `modules/home/gaming.nix` - CLI games: _2048-in-terminal, vitetris, nethack

### 6. Development Environment & Packages
- **Task ID**: `dev-environment-packages`
- **Depends On**: `flake-inputs-and-core-modules`
- **Assigned To**: `nix-dev-env-engineer` + `nix-validator`
- **Agent Type**: `nixos` / `validator`
- **Parallel**: true
- Create `modules/home/development/` directory with:
  - `modules/home/development/default.nix` - Aggregator importing all dev modules
  - `modules/home/development/development.nix` - Full dev toolchains from GitHub:
    - C/C++: gcc, gdb, gnumake
    - Go: go, gopls, golangci-lint, gofumpt
    - Java: openjdk, gradle, maven
    - JS/TS: nodejs, typescript, bun
    - Python: python3, uv
    - Rust: rustc, cargo, rustfmt, clippy
    - Zig: zig
    - Terraform tools, Kubernetes tools, Ansible, Docker-compose
    - Nix tools: nixd, nixfmt, nix-prefetch-github, nix-output-monitor, nvd
    - DB: postgresql, sqlc
    - Cloud: azure-cli, doppler
    - Utilities: jq, yq, ripgrep, shfmt, pre-commit, bruno
  - `modules/home/development/claude-code.nix` - Claude Code config with MCP servers, API keys from customsecrets, security permissions
  - `modules/home/development/opencode.nix` - OpenCode config with MCP servers
  - `modules/home/development/sidecar.nix` - TD sidecar service (needs `sidecar` and `td` flake inputs)
- Create `modules/home/backup-repos.nix` - Automated NAS backup service:
  - systemd user service + timer
  - rsync to NAS mount point from customsecrets
  - Exclusions: node_modules, target, .direnv, result
  - Desktop notifications
- Fetch and create `modules/home/scripts/` directory from GitHub
- Merge missing packages from GitHub's `packages.nix` into local:
  - Add: ffmpeg-full, imv, mpv, ncdu, onefetch, xdg-utils, libnotify (if not present), killall, man-pages, bleachbit, gnome-disk-utility, gnome-calculator, mission-center, vlc, zenity
  - Remove packages that now have dedicated modules (bat, fzf, lazygit, yazi)
  - Keep packages that are local-only additions (tokei, dust, duf, procs, bottom, zoxide, httpie, doggo, sd, choose, hyperfine, glow, nix-tree, nix-diff, comma)
- **IMPORTANT**: Some packages from GitHub (1password, discord, filezilla, gimp, libreoffice, obs-studio, thunderbird, audacity, wine) are heavy GUI apps. Include them but allow easy commenting-out for VM builds
- **IMPORTANT**: Development tools that reference `customsecrets` need the `or ""` fallback pattern

### 7. WSL & Host-Specific Support
- **Task ID**: `wsl-host-support`
- **Depends On**: `dev-environment-packages`, `security-system-integration`
- **Assigned To**: `nix-wsl-engineer` + `nix-validator`
- **Agent Type**: `nixos` / `validator`
- **Parallel**: false (depends on previous tasks)
- Create WSL-specific modules from GitHub:
  - `modules/core/default.wsl.nix` - WSL core imports (no pipewire, no steam, no samba)
  - `modules/core/wsl-overrides.nix` - lib.mkForce disables for desktop/audio/graphics/bluetooth
  - `modules/home/default.wsl.nix` - WSL home imports (no hyprland, no waybar, no wayland tools)
  - `modules/home/fonts-wsl.nix` - WSL font configuration
  - `modules/home/keyring-wsl.nix` - WSL gnome-keyring via systemd
  - `modules/home/development/default.wsl.nix` - WSL dev imports (no VS Code - use remote)
  - `modules/home/vscode-remote.nix` - VS Code Remote for WSL
- **NOTE**: Don't add a WSL host to flake.nix yet - just prepare the modules. The host config can be added later when needed

### 8. Integration & Final Build Validation
- **Task ID**: `integration-validation`
- **Depends On**: `shell-cli-tool-configs`, `security-system-integration`, `desktop-applications`, `media-entertainment`, `dev-environment-packages`, `wsl-host-support`
- **Assigned To**: `nix-integration-engineer` + `nix-validator`
- **Agent Type**: `nixos` / `validator`
- **Parallel**: false (final step)
- Update `modules/home/default.nix` to import ALL new modules:
  ```nix
  imports = [
    # Existing
    ./packages.nix ./git.nix ./starship.nix ./ghostty.nix ./tmux.nix
    ./browser.nix ./media.nix ./btop.nix ./swayosd.nix ./hyprlock.nix
    ./hypridle.nix ./hyprpaper.nix ./theming.nix ./wlogout.nix ./swaync.nix
    ./fastfetch.nix ./walker.nix ./zsh ./hyprland ./waybar
    # New - Shell & CLI
    ./bat.nix ./fzf.nix ./lazygit.nix ./vivid.nix ./yazi.nix
    # New - Security
    ./openssh.nix ./gpg.nix ./gnome.nix ./xdg-mimes.nix
    # New - Desktop Apps
    ./obsidian.nix ./vscode.nix ./discord ./micro.nix ./viewnior.nix
    # New - Media
    ./audacious.nix ./cava.nix ./spicetify.nix ./gaming.nix
    # New - Development
    ./development ./backup-repos.nix ./scripts
  ];
  ```
- Update `modules/home/default.vm.nix` - should import default.nix + vm-overrides (already does)
- Verify `modules/home/default.vm.nix` doesn't need additional VM-specific overrides for new modules
- Run full build: `nix build .#nixosConfigurations.vmware-guest.config.system.build.toplevel`
- Verify no nixfmt 3-byte icon stripping in new modules
- Verify all `customsecrets` references have `or ""` fallbacks
- Verify all executable paths in configs use `${pkgs.xxx}/bin/xxx` format
- Verify German keyboard layout (`kb_layout = "de"`) is not overridden
- Run `nix develop -c treefmt` and verify icons survive formatting

## Acceptance Criteria

1. All 35+ new home modules created and importable
2. All 7+ new core modules created and importable
3. `nix build .#nixosConfigurations.vmware-guest.config.system.build.toplevel` succeeds
4. All themed modules use Everforest palette (not Rose Pine)
5. No 3-byte Nerd Font icons in any `.nix` files (use 4-byte MDI or external files like starship.toml)
6. All `customsecrets` references use `or ""` fallback pattern
7. All executable paths use full nix store paths `${pkgs.xxx}/bin/xxx`
8. Packages removed from `packages.nix` that now have dedicated modules
9. WSL support modules exist (even if WSL host not yet in flake)
10. `modules/core/docker.nix` removed (replaced by `virtualization.nix`)
11. German keyboard layout preserved everywhere
12. `treefmt` runs without stripping any icons

## Validation Commands

- `nix build .#nixosConfigurations.vmware-guest.config.system.build.toplevel` - Full system build
- `nix develop -c treefmt` - Format and verify no icon stripping
- `nix flake check 2>&1 | head -20` - Flake validation
- `grep -r "rofi-wayland" modules/` - Should return nothing (use pkgs.rofi)
- `grep -r "noto-fonts-emoji" modules/` - Should return nothing (use noto-fonts-color-emoji)
- `grep -rn 'customsecrets\.' modules/home/ | grep -v 'or ""' | grep -v '#'` - Find missing fallbacks
- `find modules/ -name "*.nix" -exec sh -c 'xxd "$1" | grep -q "ee [89ab]" && echo "3-byte PUA in: $1"' _ {} \;` - Find 3-byte icons that will be stripped

## Notes

- **Theme mapping (Rose Pine → Everforest)**:
  - base/bg → `#2d353b`, surface → `#3d484d`, overlay → `#475258`
  - text/fg → `#d3c6aa`, subtle → `#9da9a0`, muted → `#859289`
  - love/red → `#e67e80`, gold/yellow → `#dbbc7f`, rose/orange → `#e69875`
  - pine/green → `#a7c080`, foam/aqua → `#83c092`, iris/blue → `#7fbbb3`, highlight → `#d699b6`
- **Modules intentionally NOT brought over** (superseded by local alternatives):
  - `rofi.nix` → using `walker.nix`
  - `swaylock.nix` → using `hyprlock.nix`
  - `waypaper.nix` → using `hyprpaper.nix`
  - `oh-my-posh/` → using `starship.nix`
  - `nemo.nix` → using `nautilus` (in packages.nix)
  - `nvim.nix` → skip for now (complex, 30+ plugins - can be added separately)
  - `rider.nix`, `unity.nix`, `aseprite/` → niche tools, add on-demand
- **Flake inputs that need `follows`**: spicetify-nix, nix-flatpak, yazi-plugins should follow nixpkgs
- **Sub-agents do NOT persist file writes** - team lead must verify all outputs are actually written to disk
- **nixfmt strips 3-byte UTF-8 PUA characters** - all Nerd Font icons in .nix files must use 4-byte supplementary plane (U+F0000+) MDI icons, or be in non-.nix files (like starship.toml)
