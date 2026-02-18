# Plan: Implement Desktop Host Configuration

## Task Description
Create a complete NixOS desktop host configuration for a system with an Intel i7-13700K CPU and Nvidia RTX 4070Ti Super GPU. This includes Nvidia proprietary driver support, NAS CIFS mounts, desktop-optimized Hyprland settings, gaming support (Steam/Gamescope), Flatpak, and full integration with the existing modular architecture.

## Objective
When complete, running `nix build .#nixosConfigurations.desktop.config.system.build.toplevel --impure` will succeed, and the configuration will be deployable to the desktop hardware after generating a real `hardware-configuration.nix`.

## Problem Statement
The flake currently only supports `vmware-guest` and `laptop` hosts. The desktop (primary workstation with i7-13700K + RTX 4070Ti Super) has no configuration. The old moshpitcodes.nix-main repo had a desktop config but lacked Nvidia drivers entirely (used Intel i915 only). We need to build desktop support from scratch with proper Nvidia + Wayland/Hyprland integration.

## Solution Approach
Follow the established host pattern (vmware-guest/laptop) to create a desktop host with:
- A new Nvidia driver module (`modules/core/nvidia.nix`) reusable across any Nvidia host
- Desktop-specific boot, kernel, and NAS mount configuration
- Desktop Hyprland overrides with Nvidia environment variables and multi-monitor placeholders
- A `default.desktop.nix` home-manager entry point (paralleling `default.vm.nix` and `default.laptop.nix`)
- Integration in `flake.nix` following the exact same pattern as existing hosts
- Secrets alignment: rename `nas` to `samba` in secrets.nix to match what `samba.nix` expects

## Relevant Files
Use these files to complete the task:

### Existing Files (Reference / Modify)
- `flake.nix` — Add desktop to nixosConfigurations (follow laptop/vmware-guest pattern)
- `modules/core/default.nix` — Reference only (do NOT modify; desktop imports it directly)
- `modules/core/hardware.nix` — Reference: Intel VAAPI drivers already configured here; desktop will add Nvidia extras
- `modules/core/bootloader.nix` — Reference: base boot config with Plymouth and latest kernel
- `modules/core/samba.nix` — Reference: expects `customsecrets.samba` (NOT `customsecrets.nas`)
- `modules/core/steam.nix` — Reference: Steam + Gamescope already configured
- `modules/core/flatpak.nix` — Reference: Flatpak with Wayland forcing
- `modules/home/default.nix` — Reference: base home module aggregator
- `modules/home/default.vm.nix` — Pattern: imports default.nix + host-specific overrides
- `modules/home/default.laptop.nix` — Pattern: imports default.nix + host-specific overrides
- `modules/home/hyprland/default.nix` — Base Hyprland config (monitor defaults, keybinds, rules)
- `modules/home/hyprland/vm-overrides.nix` — Pattern: override monitor, env vars, performance settings
- `modules/home/hyprland/laptop-overrides.nix` — Pattern: override monitor, brightness, lid switch
- `hosts/vmware-guest/default.nix` — Pattern: host default.nix structure
- `hosts/vmware-guest/nas-mount.nix` — Reference: VMware NAS mount (desktop uses CIFS instead)
- `hosts/laptop/default.nix` — Pattern reference
- `secrets.nix` — Needs `samba` key added (currently only has `nas`); SSH/GPG paths are VMware-specific, desktop needs NAS paths
- `secrets.nix.example` — Update to document desktop-specific secrets

### New Files
- `hosts/desktop/default.nix` — Desktop host configuration (boot, kernel, imports)
- `hosts/desktop/hardware-configuration.nix` — Placeholder (must be regenerated on real hardware)
- `hosts/desktop/nas-mount.nix` — CIFS/SMB NAS mount for UGREEN NAS
- `modules/core/nvidia.nix` — Nvidia proprietary driver module (reusable)
- `modules/home/hyprland/desktop-overrides.nix` — Desktop Hyprland: Nvidia env vars, monitor config
- `modules/home/default.desktop.nix` — Desktop home aggregator (imports default.nix + desktop-overrides)

## Implementation Phases

### Phase 1: Foundation
Create the Nvidia driver module and desktop host skeleton. These are the building blocks everything else depends on.

### Phase 2: Core Implementation
Build the desktop host configuration, NAS mount, Hyprland overrides, and home-manager entry point. Wire everything into flake.nix.

### Phase 3: Integration & Validation
Fix secrets.nix alignment (`nas` → `samba`), test the full build, verify all modules resolve, and document deployment steps.

## Team Orchestration

- You operate as the team lead and orchestrate the team to execute the plan.
- You're responsible for deploying the right team members with the right context to execute the plan.
- IMPORTANT: You NEVER operate directly on the codebase. You use `Task` and `Task*` tools to deploy team members to do the building, validating, testing, deploying, and other tasks.
- Communication is paramount. You'll use the Task* Tools to communicate with the team members and ensure they're on track to complete the plan.

### Team Members

#### Implementation Group

- Builder
  - Name: nvidia-module-builder
  - Role: Create `modules/core/nvidia.nix` — Nvidia proprietary driver configuration for RTX 4070Ti Super with Wayland/Hyprland support
  - Agent Type: nixos
  - Resume: true

- Builder
  - Name: desktop-host-builder
  - Role: Create `hosts/desktop/default.nix`, `hosts/desktop/hardware-configuration.nix` (placeholder), and `hosts/desktop/nas-mount.nix`
  - Agent Type: nixos
  - Resume: true

- Builder
  - Name: hyprland-desktop-builder
  - Role: Create `modules/home/hyprland/desktop-overrides.nix` and `modules/home/default.desktop.nix`
  - Agent Type: nixos
  - Resume: true

- Builder
  - Name: flake-integrator
  - Role: Add desktop nixosConfiguration to `flake.nix` and align `secrets.nix`/`secrets.nix.example`
  - Agent Type: nixos
  - Resume: true

#### Validation Group

- Builder
  - Name: build-validator
  - Role: Run `nix build` for desktop, vmware-guest, and laptop configs. Verify all three build successfully with zero errors.
  - Agent Type: general-purpose
  - Resume: false

- Builder
  - Name: config-reviewer
  - Role: Review all new files for correctness: Nvidia driver settings, kernel modules, NAS mount options, Hyprland env vars, secrets alignment
  - Agent Type: general-purpose
  - Resume: false

#### Documentation Group

- Builder
  - Name: docs-updater
  - Role: Update `secrets.nix.example` with desktop-specific fields and add desktop deployment notes to `docs/configuration.md`
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

## Step by Step Tasks

### 1. Create Nvidia Driver Module
- **Task ID**: create-nvidia-module
- **Depends On**: none
- **Assigned To**: nvidia-module-builder
- **Agent Type**: nixos
- **Parallel**: true (no dependencies)
- Create `modules/core/nvidia.nix` with:
  - `services.xserver.videoDrivers = [ "nvidia" ];`
  - `hardware.nvidia.modesetting.enable = true;`
  - `hardware.nvidia.open = false;` (stability for RTX 40 series)
  - `hardware.nvidia.nvidiaSettings = true;`
  - `hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.production;`
  - `hardware.nvidia.powerManagement.enable = false;` (desktop, no power saving)
  - `hardware.graphics.extraPackages` with `nvidia-vaapi-driver`, `vulkan-loader`, `vulkan-validation-layers`
  - Kernel modules: `nvidia`, `nvidia_modeset`, `nvidia_uvm`, `nvidia_drm`
  - `boot.extraModprobeConfig = "options nvidia-drm modeset=1";`
  - Environment variables: `LIBVA_DRIVER_NAME=nvidia`, `GBM_BACKEND=nvidia-drm`, `__GLX_VENDOR_LIBRARY_NAME=nvidia`
  - `environment.systemPackages` with `nvtopPackages.nvidia`
  - Module should accept `config` in its arguments for kernel package reference
  - Use `lib.mkDefault` where appropriate so hosts can override

### 2. Create Desktop Host Configuration
- **Task ID**: create-desktop-host
- **Depends On**: none
- **Assigned To**: desktop-host-builder
- **Agent Type**: nixos
- **Parallel**: true (no dependencies)
- Create `hosts/desktop/default.nix`:
  - Function args: `{ pkgs, lib, username, ... }`
  - Imports: `./hardware-configuration.nix`, `./nas-mount.nix`, `../../modules/core`, `../../modules/core/nvidia.nix`, `../../modules/core/samba.nix`, `../../modules/core/steam.nix`, `../../modules/core/flatpak.nix`
  - `networking.hostName = "desktop";`
  - Boot config:
    - `boot.consoleLogLevel = 3;`
    - `boot.initrd.verbose = false;`
    - `boot.loader.timeout = 0;`
    - initrd kernelModules: `nvidia`, `nvidia_modeset`, `nvidia_uvm`, `nvidia_drm`
    - kernelModules: `acpi_call`, `btusb`, `coretemp`, `intel_pstate`, `kvm-intel`, `msr`, `snd_hda_intel`
    - kernelParams: `intel_pstate=active`, `mitigations=auto`, `threadirqs`, `nowatchdog`, `nvidia-drm.modeset=1`, `quiet`, `splash`, `boot.shell_on_fail`, `udev.log_priority=3`, `rd.systemd.show_status=auto`
    - kernel.sysctl: `vm.swappiness=10`, `vm.dirty_ratio=60`, `vm.dirty_background_ratio=30`, `kernel.sched_autogroup_enabled=0`
  - SSH config: `services.openssh.enable = true`, port 22, password auth, allow username, no root
  - `networking.firewall.allowedTCPPorts = [ 22 ];`
- Create `hosts/desktop/hardware-configuration.nix`:
  - Placeholder with dummy UUIDs (same pattern as laptop)
  - Include comment: "PLACEHOLDER - regenerate on real hardware with: sudo nixos-generate-config --show-hardware-config"
  - Boot initrd available kernel modules: `xhci_pci`, `thunderbolt`, `nvme`, `usb_storage`, `sd_mod`
  - Dummy filesystem entries for `/` (ext4) and `/boot` (vfat)
  - Dummy swap device
  - `nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";`
  - `hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;`
- Create `hosts/desktop/nas-mount.nix`:
  - Function args: `{ lib, customsecrets, ... }`
  - CIFS mount at `/mnt/ugreen-nas` using secrets
  - Device: `"//${customsecrets.nas.host or "192.168.178.144"}/${customsecrets.nas.share or "personal_folder"}"`
  - fsType: `"cifs"`
  - Options: `credentials=/root/.secrets/samba-credentials`, `sec=ntlmssp`, `uid=1000`, `gid=100`, `file_mode=0755`, `dir_mode=0755`, `x-systemd.automount`, `x-systemd.idle-timeout=300`, `x-systemd.mount-timeout=30`, `x-systemd.requires=network-online.target`, `noauto`, `vers=3.0`, `cache=loose`, `_netdev`, `nofail`
  - NOTE: The samba.nix module (imported in default.nix) handles credential file creation. The NAS mount just defines the filesystem entry.

### 3. Create Desktop Hyprland Overrides
- **Task ID**: create-desktop-hyprland
- **Depends On**: none
- **Assigned To**: hyprland-desktop-builder
- **Agent Type**: nixos
- **Parallel**: true (no dependencies)
- Create `modules/home/hyprland/desktop-overrides.nix`:
  - Function args: `{ pkgs, lib, ... }`
  - Comment header: "Hyprland desktop-specific overrides (i7-13700K, RTX 4070Ti Super)"
  - Monitor config: `monitor = lib.mkForce [ ",2560x1440@60,auto,1" ];` with comments showing multi-monitor example
  - Nvidia environment variables: `env = [ "LIBVA_DRIVER_NAME,nvidia" "XDG_SESSION_TYPE,wayland" "GBM_BACKEND,nvidia-drm" "__GLX_VENDOR_LIBRARY_NAME,nvidia" ];`
  - Full blur/shadows enabled: `decoration.blur.enabled = lib.mkDefault true;` and `decoration.shadow.enabled = lib.mkDefault true;`
  - Full animations enabled: `animations.enabled = lib.mkDefault true;`
  - Cursor size: `env` should include `"XCURSOR_SIZE,24"`
- Create `modules/home/default.desktop.nix`:
  - Follow exact pattern of `default.vm.nix` and `default.laptop.nix`
  - Import `./default.nix` and `./hyprland/desktop-overrides.nix`

### 4. Integrate Desktop into Flake
- **Task ID**: integrate-flake
- **Depends On**: create-nvidia-module, create-desktop-host, create-desktop-hyprland
- **Assigned To**: flake-integrator
- **Agent Type**: nixos
- **Parallel**: false (depends on all file creation tasks)
- Add `desktop` nixosConfiguration to `flake.nix`:
  - Follow exact pattern of laptop/vmware-guest blocks
  - `host = "desktop";`
  - Home-manager users import: `./modules/home/default.desktop.nix`
  - All other settings identical to laptop block
- Add `samba` key to `secrets.nix` for `samba.nix` compatibility:
  - `samba = { username = "moshpithome"; password = "..."; domain = "WORKGROUP"; };`
  - The existing `nas` key should stay (used by nas-mount.nix for host/share)
  - Add desktop-specific SSH key paths as comments
- Update `secrets.nix.example` with:
  - `samba` section template
  - Desktop deployment notes
  - SSH key paths for desktop (NAS-based vs HGFS-based)
- Update `flake.nix` description from "VMware Guest" to something more general

### 5. Validate All Builds
- **Task ID**: validate-builds
- **Depends On**: integrate-flake
- **Assigned To**: build-validator
- **Agent Type**: general-purpose
- **Parallel**: false (must run after integration)
- Run: `nix build .#nixosConfigurations.desktop.config.system.build.toplevel --impure 2>&1`
- Run: `nix build .#nixosConfigurations.vmware-guest.config.system.build.toplevel --impure 2>&1`
- Run: `nix build .#nixosConfigurations.laptop.config.system.build.toplevel --impure 2>&1`
- All three MUST succeed with zero errors
- If any fail, identify the error, fix it, and rebuild
- Verify the Nvidia driver derivation appears in the desktop build output
- Verify the CIFS mount unit appears in the desktop build output

### 6. Review Configuration Correctness
- **Task ID**: review-config
- **Depends On**: validate-builds
- **Assigned To**: config-reviewer
- **Agent Type**: general-purpose
- **Parallel**: false (runs after builds pass)
- Verify `modules/core/nvidia.nix`:
  - Uses `config.boot.kernelPackages.nvidiaPackages.production` (not hardcoded)
  - Has `modesetting.enable = true`
  - Has `open = false` (stability)
  - Environment variables correct for Wayland
- Verify `hosts/desktop/default.nix`:
  - Does NOT import `vm-overrides.nix`
  - Does NOT set `WLR_NO_HARDWARE_CURSORS` or `LIBGL_ALWAYS_SOFTWARE`
  - Has all required kernel modules for i7-13700K
  - Does NOT duplicate settings from `modules/core/bootloader.nix` (e.g., don't re-set `kernelPackages`)
- Verify `hosts/desktop/nas-mount.nix`:
  - CIFS options include `_netdev`, `nofail`, `x-systemd.automount`
  - Uses secrets for host/share values
- Verify `modules/home/hyprland/desktop-overrides.nix`:
  - Has Nvidia-specific `env` variables
  - Does NOT disable blur/shadows (desktop has full GPU)
  - Monitor config uses `lib.mkForce`
- Verify `flake.nix`:
  - Desktop block follows same pattern as laptop/vmware-guest
  - Imports `default.desktop.nix` for home-manager
- Verify `secrets.nix`:
  - Has both `nas` and `samba` keys
  - `samba` has `username`, `password`, `domain`

### 7. Update Documentation
- **Task ID**: update-docs
- **Depends On**: review-config
- **Assigned To**: docs-updater
- **Agent Type**: general-purpose
- **Parallel**: false (runs after review confirms correctness)
- Update `secrets.nix.example`:
  - Add `samba` section with placeholder values
  - Add comments for desktop-specific SSH/GPG paths
  - Ensure all keys used by any host are documented
- If `docs/configuration.md` exists, add desktop deployment instructions:
  - Hardware requirements (generate hardware-configuration.nix)
  - NAS credentials setup
  - Monitor configuration adjustment after first boot
  - Build command: `sudo nixos-rebuild switch --flake .#desktop --impure`

## Acceptance Criteria
- `nix build .#nixosConfigurations.desktop.config.system.build.toplevel --impure` succeeds
- `nix build .#nixosConfigurations.vmware-guest.config.system.build.toplevel --impure` succeeds (no regression)
- `nix build .#nixosConfigurations.laptop.config.system.build.toplevel --impure` succeeds (no regression)
- `modules/core/nvidia.nix` exists and is imported only by desktop (not globally)
- Desktop host imports: core modules, nvidia.nix, samba.nix, steam.nix, flatpak.nix
- Desktop Hyprland overrides include Nvidia-specific environment variables
- NAS mount uses CIFS with proper options and credentials from secrets
- `secrets.nix` has both `nas` (host/share) and `samba` (credentials) keys
- `secrets.nix.example` documents all required keys for desktop deployment
- No regressions in vmware-guest or laptop configurations
- German keyboard layout (`kb_layout = "de"`) inherited from base config (not overridden)

## Validation Commands
Execute these commands to validate the task is complete:

- `nix build .#nixosConfigurations.desktop.config.system.build.toplevel --impure` — Desktop build succeeds
- `nix build .#nixosConfigurations.vmware-guest.config.system.build.toplevel --impure` — VMware build still works
- `nix build .#nixosConfigurations.laptop.config.system.build.toplevel --impure` — Laptop build still works
- `grep -r "nvidia" modules/core/nvidia.nix` — Nvidia module exists with driver config
- `grep "desktop" flake.nix` — Desktop host registered in flake
- `grep "samba" secrets.nix` — Samba credentials present for NAS mount
- `ls hosts/desktop/` — Desktop host directory exists with default.nix, hardware-configuration.nix, nas-mount.nix

## Notes
- The `hardware-configuration.nix` is a PLACEHOLDER. Before deploying to real hardware, run:
  ```bash
  sudo nixos-generate-config --show-hardware-config > hosts/desktop/hardware-configuration.nix
  ```
- The old desktop config (moshpitcodes.nix-main) did NOT have Nvidia drivers. The RTX 4070Ti Super was using Intel i915 fallback. This plan adds proper Nvidia support from scratch.
- Monitor configuration defaults to single 2560x1440@60Hz. After first deployment, adjust `desktop-overrides.nix` to match actual multi-monitor layout. The old config had 3 external displays + laptop screen (DP-5, DP-6, DP-7, eDP-1).
- The `nvidia.open = false` setting is recommended for RTX 40 series stability. The open source kernel modules are still alpha quality for this generation.
- `samba.nix` expects `customsecrets.samba` but secrets.nix currently only has `customsecrets.nas`. Both keys are needed: `nas` for host/share info used by nas-mount.nix, `samba` for username/password/domain used by samba.nix credential file creation.
- Desktop does NOT need: `vm-overrides.nix`, `hgfs-mount.nix`, `WLR_NO_HARDWARE_CURSORS`, `LIBGL_ALWAYS_SOFTWARE`, `WLR_RENDERER_ALLOW_SOFTWARE`
