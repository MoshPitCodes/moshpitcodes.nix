# Plan: Create Laptop Host Configuration

## Task Description
Create a complete laptop host configuration for the ASUS Zenbook 14X OLED within the shifttab.nix flake. This involves creating the host directory structure (`hosts/laptop/`), adding a flake.nix entry, creating a laptop-specific Home Manager aggregator, and adding laptop-specific modules for power management, battery, OLED display, WiFi, Bluetooth, touchpad, and backlight. The configuration must integrate cleanly with the existing modular architecture and reuse all shared core/home modules.

## Objective
When complete, `nix build .#nixosConfigurations.laptop.config.system.build.toplevel` succeeds, and the laptop host can be deployed with full Hyprland desktop, power management (TLP), battery monitoring, OLED-optimized display settings, Intel GPU acceleration, WiFi/Bluetooth, and all existing home modules.

## Problem Statement
The shifttab.nix flake currently only supports a single host (`vmware-guest`). The user has an ASUS Zenbook 14X OLED laptop that needs its own host configuration. The old config (`moshpitcodes.nix-main`) has a `hosts/laptop/` with extensive power management, kernel modules, and TLP configuration that should be ported and improved. The current core modules use `vm-overrides.nix` to disable laptop features (Bluetooth, TLP, lid switch) — those overrides must NOT apply to the laptop host.

## Solution Approach
1. Create `hosts/laptop/default.nix` with laptop-specific boot, power, and hardware config (ported from old config)
2. Create a placeholder `hosts/laptop/hardware-configuration.nix` (user generates the real one with `nixos-generate-config`)
3. Create `modules/home/default.laptop.nix` that imports the base `default.nix` plus laptop-specific Hyprland overrides
4. Create `modules/home/hyprland/laptop-overrides.nix` for laptop monitor config, blur/shadows enabled, brightness keys
5. Add `battery` and `backlight` modules to waybar for the laptop
6. Update `modules/core/default.nix` to remove `vm-overrides.nix` from the shared core (move it to the vmware-guest host import instead)
7. Add the `laptop` entry to `flake.nix`

## Relevant Files

### Existing Files (to modify)
- `flake.nix` — Add `laptop` to `nixosConfigurations` (currently only has `vmware-guest`)
- `modules/core/default.nix` — Remove `./vm-overrides.nix` import (it's VMware-specific, should be imported by `hosts/vmware-guest/default.nix` instead)
- `hosts/vmware-guest/default.nix` — Add `../../modules/core/vm-overrides.nix` import (moved from core/default.nix)
- `modules/home/waybar/default.nix` — Add conditional `battery` and `backlight` modules for laptop host

### Existing Files (reference only)
- `modules/core/bootloader.nix` — Base boot config (systemd-boot, latest kernel, plymouth)
- `modules/core/hardware.nix` — Base hardware (Intel VAAPI, Bluetooth enabled by default)
- `modules/core/services.nix` — Base services (logind lid switch handling already correct for laptop)
- `modules/core/network.nix` — NetworkManager already enabled
- `modules/core/wayland.nix` — Hyprland/UWSM config (shared)
- `modules/core/security.nix` — PAM for swaylock/hyprlock
- `modules/home/default.nix` — Full home module aggregator
- `modules/home/default.vm.nix` — VM-specific home wrapper (pattern to follow)
- `modules/home/hyprland/default.nix` — Base Hyprland config (monitor, keybindings, window rules)
- `modules/home/hyprland/vm-overrides.nix` — VM overrides pattern (disable blur/shadow, software cursor)
- `modules/home/hypridle.nix` — Idle management (brightnessctl already used)
- `modules/home/swaylock.nix` — Lock screen (shared)
- `hosts/vmware-guest/default.nix` — Existing host config (pattern to follow)
- `hosts/vmware-guest/hardware-configuration.nix` — Hardware config pattern
- Old config: `moshpitcodes.nix-main/hosts/laptop/default.nix` — Source for TLP, kernel modules, boot params

### New Files
- `hosts/laptop/default.nix` — Laptop host configuration (boot, power, hardware, SSH)
- `hosts/laptop/hardware-configuration.nix` — Placeholder (user must generate with `nixos-generate-config`)
- `modules/home/default.laptop.nix` — Laptop home aggregator (imports base + laptop overrides)
- `modules/home/hyprland/laptop-overrides.nix` — Laptop-specific Hyprland settings (monitor, blur, brightness keys)

## Implementation Phases

### Phase 1: Foundation
- Move `vm-overrides.nix` import from `modules/core/default.nix` to `hosts/vmware-guest/default.nix`
- Create placeholder `hosts/laptop/hardware-configuration.nix`
- Create `hosts/laptop/default.nix` with boot, power management, kernel modules

### Phase 2: Core Implementation
- Create `modules/home/hyprland/laptop-overrides.nix` for laptop display/input settings
- Create `modules/home/default.laptop.nix` as laptop home aggregator
- Update `modules/home/waybar/default.nix` to conditionally add battery/backlight modules
- Add `laptop` entry to `flake.nix`

### Phase 3: Integration & Polish
- Validate the full build with `nix build .#nixosConfigurations.laptop.config.system.build.toplevel`
- Validate existing vmware-guest build still works
- Review all changes for correctness

## Team Orchestration

- You operate as the team lead and orchestrate the team to execute the plan.
- You're responsible for deploying the right team members with the right context to execute the plan.
- IMPORTANT: You NEVER operate directly on the codebase. You use `Task` and `Task*` tools to deploy team members to do the building, validating, testing, deploying, and other tasks.

### Team Members

- Builder
  - Name: builder-foundation
  - Role: Move vm-overrides.nix import, create host directory structure and placeholder hardware-configuration.nix
  - Agent Type: nixos
  - Resume: true

- Builder
  - Name: builder-laptop-host
  - Role: Create the laptop host default.nix with boot config, power management (TLP), kernel modules, hardware
  - Agent Type: nixos
  - Resume: true

- Builder
  - Name: builder-home-laptop
  - Role: Create laptop Home Manager aggregator and Hyprland laptop overrides
  - Agent Type: nixos
  - Resume: true

- Builder
  - Name: builder-waybar-battery
  - Role: Add conditional battery and backlight modules to waybar for laptop host
  - Agent Type: nixos
  - Resume: true

- Builder
  - Name: builder-flake
  - Role: Add laptop nixosConfiguration entry to flake.nix
  - Agent Type: nixos
  - Resume: true

- Builder
  - Name: validator-build
  - Role: Validate both laptop and vmware-guest builds succeed
  - Agent Type: nixos
  - Resume: true

- Builder
  - Name: validator-review
  - Role: Review all changes for correctness, conventions, and completeness
  - Agent Type: review-code
  - Resume: true

- Builder
  - Name: documenter
  - Role: Update project documentation to reflect new laptop host
  - Agent Type: general-purpose
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

This ensures full traceability from planning → implementation → validation.

## Step by Step Tasks

### 1. Move vm-overrides.nix Import
- **Task ID**: move-vm-overrides
- **Depends On**: none
- **Assigned To**: builder-foundation
- **Agent Type**: nixos
- **Parallel**: true
- Remove `./vm-overrides.nix` from `modules/core/default.nix` imports list
- Add `../../modules/core/vm-overrides.nix` to `hosts/vmware-guest/default.nix` imports list
- This ensures VM-specific overrides (disable Bluetooth, TLP, lid switch) only apply to the VMware host

### 2. Create Laptop Hardware Configuration Placeholder
- **Task ID**: create-hw-config
- **Depends On**: none
- **Assigned To**: builder-foundation
- **Agent Type**: nixos
- **Parallel**: true (same agent as task 1)
- Create `hosts/laptop/hardware-configuration.nix` with placeholder content
- Include a clear comment that the user must regenerate with `nixos-generate-config --show-hardware-config > hosts/laptop/hardware-configuration.nix`
- Use a template based on ASUS Zenbook 14X OLED: NVMe SSD, Intel CPU (i7-13700H or similar), Intel Iris Xe GPU, 2880x1800 OLED display
- Include `nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";`

### 3. Create Laptop Host Configuration
- **Task ID**: create-laptop-host
- **Depends On**: create-hw-config
- **Assigned To**: builder-laptop-host
- **Agent Type**: nixos
- **Parallel**: false
- Create `hosts/laptop/default.nix` with:
  - Import `./hardware-configuration.nix` and `../../modules/core`
  - `networking.hostName = "laptop";`
  - Boot config: silent boot, i915 early KMS, Intel kernel modules (iwlwifi, btusb, coretemp, intel_pstate, hid_multitouch, acpi_call, snd_hda_intel, kvm-intel, USB ethernet adapters)
  - Kernel params: `i915.force_probe=a7a0`, `intel_pstate=active`, `threadirqs`, `nowatchdog`, `nvme.noacpi=1`, `quiet`, `splash`
  - Kernel sysctl: swappiness=10, vfs_cache_pressure=50, dirty_background_ratio=30
  - Boot loader timeout = 0 (hidden, press key to see)
  - TLP power management with full AC/battery profiles (ported from old config)
  - UPower battery monitoring (percentageLow=20, percentageCritical=5, criticalPowerAction=PowerOff)
  - SSH (password auth disabled, key-only, allow username)
  - Laptop-specific packages: `acpi`, `brightnessctl`, `cpupower-gui`, `powertop`
  - Firewall: allow TCP 22

### 4. Create Hyprland Laptop Overrides
- **Task ID**: create-hyprland-laptop
- **Depends On**: none
- **Assigned To**: builder-home-laptop
- **Agent Type**: nixos
- **Parallel**: true
- Create `modules/home/hyprland/laptop-overrides.nix` with:
  - Monitor config for ASUS Zenbook 14X OLED: `"eDP-1,2880x1800@120,auto,1.5"` (120Hz OLED, 1.5x scale)
  - Keep blur and shadows ENABLED (real GPU, not software rendering)
  - Keep full animations enabled
  - Add brightness key bindings: `XF86MonBrightnessUp` → `swayosd-client --brightness raise`, `XF86MonBrightnessDown` → `swayosd-client --brightness lower`
  - Touchpad config already in base (natural_scroll = true) — no override needed
  - NO env overrides (no WLR_NO_HARDWARE_CURSORS, no software rendering)

### 5. Create Laptop Home Manager Aggregator
- **Task ID**: create-home-laptop
- **Depends On**: create-hyprland-laptop
- **Assigned To**: builder-home-laptop
- **Agent Type**: nixos
- **Parallel**: false (same agent as task 4)
- Create `modules/home/default.laptop.nix` following `default.vm.nix` pattern:
  ```nix
  { ... }:
  {
    imports = [
      ./default.nix
      ./hyprland/laptop-overrides.nix
    ];
  }
  ```

### 6. Add Battery and Backlight to Waybar
- **Task ID**: waybar-battery
- **Depends On**: none
- **Assigned To**: builder-waybar-battery
- **Agent Type**: nixos
- **Parallel**: true
- Update `modules/home/waybar/default.nix`:
  - Add `host` to the function arguments
  - Add conditional `battery` module to `modules-right` when `host != "vmware-guest"`
  - Add `backlight` module to `modules-right` when `host != "vmware-guest"`
  - Add battery widget config:
    ```nix
    battery = {
      states = { warning = 30; critical = 15; };
      format = "{icon} {capacity}%";
      format-charging = "󰂄 {capacity}%";
      format-plugged = "󰂄 {capacity}%";
      format-alt = "{icon} {time}";
      format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
    };
    ```
  - Add backlight widget config:
    ```nix
    backlight = {
      format = "{icon} {percent}%";
      format-icons = [ "󰃞" "󰃟" "󰃠" ];
      on-scroll-up = "${pkgs.swayosd}/bin/swayosd-client --brightness raise";
      on-scroll-down = "${pkgs.swayosd}/bin/swayosd-client --brightness lower";
    };
    ```
  - Add Everforest-themed CSS for battery and backlight widgets

### 7. Add Laptop to flake.nix
- **Task ID**: update-flake
- **Depends On**: move-vm-overrides, create-laptop-host, create-home-laptop
- **Assigned To**: builder-flake
- **Agent Type**: nixos
- **Parallel**: false
- Add `laptop` nixosConfiguration to `flake.nix`:
  ```nix
  laptop =
    let
      host = "laptop";
    in
    nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit self inputs host customsecrets;
        username = customsecrets.username;
      };
      modules = [
        ./hosts/${host}
        home-manager.nixosModules.home-manager
        {
          nixpkgs.config.allowUnfree = true;
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = {
              inherit self inputs host customsecrets;
              username = customsecrets.username;
            };
            users.${customsecrets.username} = import ./modules/home/default.laptop.nix;
          };
        }
      ];
    };
  ```
- Note: Uses `default.laptop.nix` instead of `default.vm.nix`

### 8. Validate Builds
- **Task ID**: validate-builds
- **Depends On**: move-vm-overrides, create-laptop-host, create-home-laptop, waybar-battery, update-flake
- **Assigned To**: validator-build
- **Agent Type**: nixos
- **Parallel**: false
- Run `nix build .#nixosConfigurations.laptop.config.system.build.toplevel` — must succeed
- Run `nix build .#nixosConfigurations.vmware-guest.config.system.build.toplevel` — must still succeed (regression check)
- If either fails, diagnose and fix the issues

### 9. Code Review
- **Task ID**: review-all
- **Depends On**: validate-builds
- **Assigned To**: validator-review
- **Agent Type**: review-code
- **Parallel**: false
- Review all new and modified files for:
  - Correct Nix syntax and conventions
  - All executables use full `${pkgs.xxx}/bin/xxx` store paths
  - German keyboard layout (`kb_layout = "de"`)
  - Everforest theme consistency
  - No hardcoded usernames or paths
  - `lib.mkDefault` / `lib.mkForce` used appropriately
  - No deprecated options (`windowrulev2`, `nixfmt-rfc-style`, `initExtra`, etc.)
  - Correct package names (e.g., `pkgs.rofi` not `pkgs.rofi-wayland`)

### 10. Update Documentation
- **Task ID**: update-docs
- **Depends On**: review-all
- **Assigned To**: documenter
- **Agent Type**: general-purpose
- **Parallel**: false
- Update `docs/migration-from-old-config.md` to mark laptop host as migrated
- Add deployment instructions for laptop host to existing docs
- Note that `hardware-configuration.nix` must be generated on the actual laptop hardware

## Acceptance Criteria
- `nix build .#nixosConfigurations.laptop.config.system.build.toplevel` builds successfully
- `nix build .#nixosConfigurations.vmware-guest.config.system.build.toplevel` still builds successfully (no regression)
- `hosts/laptop/default.nix` contains TLP config, Intel kernel modules, UPower, silent boot
- `hosts/laptop/hardware-configuration.nix` exists with clear placeholder instructions
- `modules/home/default.laptop.nix` imports base + laptop Hyprland overrides
- `modules/home/hyprland/laptop-overrides.nix` has correct OLED monitor config (2880x1800@120, 1.5x scale)
- `modules/core/default.nix` no longer imports `vm-overrides.nix`
- `hosts/vmware-guest/default.nix` imports `vm-overrides.nix` directly
- Waybar shows battery and backlight widgets on laptop host but not on vmware-guest
- All Nix files use correct conventions (full store paths, German layout, Everforest colors)
- Brightness keys bound to `swayosd-client --brightness raise/lower`

## Validation Commands
Execute these commands to validate the task is complete:

- `nix build .#nixosConfigurations.laptop.config.system.build.toplevel` — Laptop build succeeds
- `nix build .#nixosConfigurations.vmware-guest.config.system.build.toplevel` — VMware guest build still succeeds (regression test)
- `nix flake check` — Flake-level validation passes
- `grep -r "vm-overrides" modules/core/default.nix` — Should return nothing (moved out)
- `grep -r "vm-overrides" hosts/vmware-guest/default.nix` — Should find the import
- `grep "battery" modules/home/waybar/default.nix` — Should find battery widget config
- `grep "laptop" flake.nix` — Should find laptop nixosConfiguration entry

## Notes
- The `hardware-configuration.nix` is a PLACEHOLDER. The user MUST run `nixos-generate-config --show-hardware-config > hosts/laptop/hardware-configuration.nix` on the actual laptop hardware before deploying
- The ASUS Zenbook 14X OLED has an Intel i7-13700H (or similar Raptor Lake) with Intel Iris Xe graphics — `i915.force_probe=a7a0` may need adjustment based on exact GPU PCI ID
- TLP and power-profiles-daemon conflict — the core modules should NOT enable power-profiles-daemon when TLP is active (the vm-overrides already force-disable TLP, so this is fine for VMware)
- The old config uses `mac-style-plymouth` theme which requires `pkgs.mac-style-plymouth` — the new config uses the default Plymouth. Consider this a future enhancement
- Monitor resolution `2880x1800@120` with scale `1.5` gives an effective resolution of 1920x1200 — ideal for 14" OLED
- OLED-specific considerations: avoid static UI elements at full brightness to prevent burn-in. The hypridle dim-before-lock stage helps with this
