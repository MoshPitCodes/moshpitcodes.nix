# Plan: VMware Host NixOS Configuration Implementation

## Task Description
Implement the VMware guest host configuration for a new NixOS system from scratch. This involves creating the foundational flake structure, core system modules, home-manager modules, and VMware-specific configurations that enable a fully functional NixOS system running as a VMware guest with Hyprland desktop environment.

## Objective
Create a complete, working NixOS configuration for VMware guest deployment that includes:
- Flake-based configuration with proper inputs and outputs
- VMware-specific kernel modules and guest additions
- Hyprland Wayland compositor with VM-optimized settings
- Home Manager integration for user-level configuration
- Secrets management infrastructure
- Development tools and shell configuration

## Problem Statement
Building a NixOS configuration from scratch requires careful orchestration of multiple interdependent components:
1. The flake must define inputs before hosts can reference them
2. Core modules must exist before hosts can import them
3. Home modules depend on core user configuration
4. VMware-specific overrides must layer on top of base configurations
5. Secrets management must be in place for user creation and service configuration

Without proper sequencing, circular dependencies and missing references will cause build failures.

## Solution Approach
Implement the configuration in phases, starting with the foundation (flake.nix, secrets template), then core system modules, followed by home-manager modules, and finally the VMware-specific host configuration. Each phase builds on the previous, ensuring all dependencies are satisfied before they're referenced.

The architecture follows the existing moshpitcodes.nix pattern:
- `flake.nix` - Entry point with inputs, overlays, and host configurations
- `modules/core/` - System-level NixOS modules (bootloader, network, wayland, etc.)
- `modules/home/` - User-level Home Manager modules (shell, editors, hyprland, etc.)
- `hosts/vmware-guest/` - VMware-specific configuration and hardware setup
- `secrets.nix` - Git-ignored credentials and API keys

## Relevant Files

### Reference Files (from moshpitcodes.nix-main)
- `~/Development/moshpitcodes.nix-main/flake.nix` - Flake structure and patterns
- `~/Development/moshpitcodes.nix-main/hosts/vmware-guest/default.nix` - VMware host config
- `~/Development/moshpitcodes.nix-main/hosts/vmware-guest/hardware-configuration.nix` - VMware hardware
- `~/Development/moshpitcodes.nix-main/modules/core/default.nix` - Core module aggregation
- `~/Development/moshpitcodes.nix-main/modules/core/vm-overrides.nix` - VM-specific overrides
- `~/Development/moshpitcodes.nix-main/modules/core/user.nix` - User and Home Manager setup
- `~/Development/moshpitcodes.nix-main/modules/core/system.nix` - Nix settings and locale
- `~/Development/moshpitcodes.nix-main/modules/core/wayland.nix` - Hyprland configuration
- `~/Development/moshpitcodes.nix-main/modules/home/default.nix` - Home module aggregation
- `~/Development/moshpitcodes.nix-main/modules/home/default.vm.nix` - VM home overrides
- `~/Development/moshpitcodes.nix-main/modules/home/hyprland/vm-overrides.nix` - Hyprland VM settings

### New Files to Create
- `flake.nix` - Main entry point
- `secrets.nix.example` - Secrets template
- `modules/core/default.nix` - Core module aggregator
- `modules/core/bootloader.nix` - Boot configuration
- `modules/core/system.nix` - Nix settings, locale, timezone
- `modules/core/network.nix` - NetworkManager, firewall
- `modules/core/security.nix` - Sudo, PAM, RTKit
- `modules/core/user.nix` - User creation, Home Manager integration
- `modules/core/wayland.nix` - Hyprland, XDG portals
- `modules/core/pipewire.nix` - Audio configuration
- `modules/core/services.nix` - System services
- `modules/core/vm-overrides.nix` - VM-specific overrides
- `modules/home/default.nix` - Home module aggregator
- `modules/home/default.vm.nix` - VM-specific home config
- `modules/home/zsh/default.nix` - Shell configuration
- `modules/home/starship.nix` - Shell prompt
- `modules/home/git.nix` - Git configuration
- `modules/home/ghostty.nix` - Terminal emulator
- `modules/home/hyprland/default.nix` - Hyprland user config
- `modules/home/hyprland/vm-overrides.nix` - Hyprland VM settings
- `modules/home/waybar/default.nix` - Status bar
- `modules/home/packages.nix` - User packages
- `hosts/vmware-guest/default.nix` - VMware host configuration
- `hosts/vmware-guest/hardware-configuration.nix` - VMware hardware config

## Implementation Phases

### Phase 1: Foundation
- Create `flake.nix` with essential inputs (nixpkgs, home-manager, hyprland)
- Create `secrets.nix.example` template
- Establish directory structure for modules and hosts
- Set up basic Nix settings and experimental features

### Phase 2: Core Implementation
- Implement core system modules (bootloader, network, security, services)
- Implement user module with Home Manager integration
- Implement Wayland/Hyprland system-level configuration
- Create VM-specific overrides module
- Implement essential home modules (shell, git, terminal)
- Create Hyprland user configuration with VM overrides

### Phase 3: Integration & Polish
- Wire up VMware guest host configuration
- Create hardware-configuration.nix for VMware
- Test flake evaluation and build
- Validate all module imports resolve correctly
- Verify VMware guest additions and kernel modules

## Team Orchestration

- You operate as the team lead and orchestrate the team to execute the plan.
- You're responsible for deploying the right team members with the right context to execute the plan.
- IMPORTANT: You NEVER operate directly on the codebase. You use `Task` and `Task*` tools to deploy team members to do the building, validating, testing, deploying, and other tasks.
  - This is critical. Your job is to act as a high level director of the team, not a builder.
  - Your role is to validate all work is going well and make sure the team is on track to complete the plan.
  - You'll orchestrate this by using the Task* Tools to manage coordination between the team members.
  - Communication is paramount. You'll use the Task* Tools to communicate with the team members and ensure they're on track to complete the plan.
- Take note of the session id of each team member. This is how you'll reference them.

### Team Members

**Task 1: Foundation Setup**
- Builder
  - Name: foundation-engineer
  - Role: Create flake.nix, secrets template, and directory structure
  - Agent Type: nixos
  - Model: opus
  - Resume: true

- Validator
  - Name: foundation-validator
  - Role: Validate flake structure, inputs, and secrets template
  - Agent Type: validator
  - Model: sonnet
  - Resume: false

**Task 2: Core System Modules**
- Builder
  - Name: core-modules-engineer
  - Role: Implement all core system modules (bootloader, network, security, services, user, wayland)
  - Agent Type: nixos
  - Model: opus
  - Resume: true

- Validator
  - Name: core-modules-validator
  - Role: Validate core module syntax, imports, and NixOS patterns
  - Agent Type: validator
  - Model: sonnet
  - Resume: false

**Task 3: Home Manager Modules**
- Builder
  - Name: home-modules-engineer
  - Role: Implement home-manager modules (shell, git, terminal, hyprland, waybar)
  - Agent Type: nixos
  - Model: opus
  - Resume: true

- Validator
  - Name: home-modules-validator
  - Role: Validate home module syntax and Home Manager patterns
  - Agent Type: validator
  - Model: sonnet
  - Resume: false

**Task 4: VMware Host Configuration**
- Builder
  - Name: vmware-host-engineer
  - Role: Create VMware-specific host configuration and hardware config
  - Agent Type: nixos
  - Model: opus
  - Resume: true

- Validator
  - Name: vmware-host-validator
  - Role: Validate VMware configuration, kernel modules, and guest additions
  - Agent Type: validator
  - Model: sonnet
  - Resume: false

**Task 5: Final Integration**
- Builder
  - Name: integration-engineer
  - Role: Wire up all modules, resolve any import issues, finalize configuration
  - Agent Type: nixos
  - Model: opus
  - Resume: true

- Validator
  - Name: final-validator
  - Role: Run full validation suite, verify flake builds, check all acceptance criteria
  - Agent Type: validator
  - Model: sonnet
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

### 1. Create Flake Foundation
- **Task ID**: create-flake-foundation
- **Depends On**: none
- **Assigned To**: foundation-engineer
- **Agent Type**: nixos
- **Parallel**: false
- Create `flake.nix` with inputs: nixpkgs (unstable), home-manager, hyprland
- Define outputs structure with nixosConfigurations.vmware-guest
- Set up specialArgs for customsecrets, username, host, inputs
- Configure binary caches (nix-community, hyprland)
- Create `secrets.nix.example` with required keys structure
- Create directory structure: `modules/core/`, `modules/home/`, `hosts/vmware-guest/`

### 2. Validate Flake Foundation
- **Task ID**: validate-flake-foundation
- **Depends On**: create-flake-foundation
- **Assigned To**: foundation-validator
- **Agent Type**: validator
- **Parallel**: false
- Verify flake.nix syntax is valid
- Check all required inputs are defined
- Validate secrets.nix.example has all required keys
- Confirm directory structure exists
- Verify specialArgs pattern matches reference implementation

### 3. Implement Core System Modules
- **Task ID**: implement-core-modules
- **Depends On**: validate-flake-foundation
- **Assigned To**: core-modules-engineer
- **Agent Type**: nixos
- **Parallel**: false
- Create `modules/core/default.nix` importing all core modules
- Implement `bootloader.nix`: systemd-boot, EFI, Linux kernel
- Implement `system.nix`: Nix settings, flakes, experimental features, locale, timezone
- Implement `network.nix`: NetworkManager, firewall, DNS
- Implement `security.nix`: sudo, PAM (swaylock), RTKit
- Implement `services.nix`: GVFS, D-Bus, fstrim, logind
- Implement `pipewire.nix`: Audio server configuration
- Implement `wayland.nix`: Hyprland system config, XDG portals
- Implement `user.nix`: User creation, Home Manager integration, shell setup
- Implement `vm-overrides.nix`: Disable Bluetooth, TLP, power-profiles-daemon

### 4. Validate Core System Modules
- **Task ID**: validate-core-modules
- **Depends On**: implement-core-modules
- **Assigned To**: core-modules-validator
- **Agent Type**: validator
- **Parallel**: false
- Verify each module has correct function signature ({ config, pkgs, lib, ... })
- Check all imports resolve correctly
- Validate lib.mkForce usage in vm-overrides.nix
- Confirm user.nix properly integrates Home Manager
- Verify wayland.nix configures XDG portals correctly
- Check security.nix enables PAM for swaylock

### 5. Implement Home Manager Modules
- **Task ID**: implement-home-modules
- **Depends On**: validate-core-modules
- **Assigned To**: home-modules-engineer
- **Agent Type**: nixos
- **Parallel**: false
- Create `modules/home/default.nix` importing all home modules
- Create `modules/home/default.vm.nix` with VM-specific imports
- Implement `zsh/default.nix`: Zsh shell with aliases, keybinds
- Implement `starship.nix`: Shell prompt configuration
- Implement `git.nix`: Git config with delta, GPG signing support
- Implement `ghostty.nix`: Terminal emulator configuration
- Implement `hyprland/default.nix`: Hyprland user config, keybinds, rules
- Implement `hyprland/vm-overrides.nix`: WLR_NO_HARDWARE_CURSORS, software rendering
- Implement `waybar/default.nix`: Status bar with JSON settings
- Implement `packages.nix`: Essential user packages

### 6. Validate Home Manager Modules
- **Task ID**: validate-home-modules
- **Depends On**: implement-home-modules
- **Assigned To**: home-modules-validator
- **Agent Type**: validator
- **Parallel**: false
- Verify default.nix imports all required modules
- Check default.vm.nix imports default.nix and vm-overrides
- Validate git.nix accesses customsecrets correctly
- Confirm hyprland config uses proper Home Manager options
- Verify waybar configuration is valid JSON
- Check all home.packages are valid nixpkgs references

### 7. Create VMware Host Configuration
- **Task ID**: create-vmware-host
- **Depends On**: validate-home-modules
- **Assigned To**: vmware-host-engineer
- **Agent Type**: nixos
- **Parallel**: false
- Create `hosts/vmware-guest/default.nix` with:
  - Import hardware-configuration.nix
  - Import core modules and vm-overrides.nix
  - Configure systemd-boot with EFI
  - Set VMware kernel modules: vmw_vsock_vmci_transport, vmw_balloon, vmwgfx
  - Blacklist Intel modules: i915, intel_agp
  - Enable virtualisation.vmware.guest with headless=false
  - Configure services.xserver.videoDrivers = ["vmware"]
  - Set environment variables: WLR_NO_HARDWARE_CURSORS, WLR_RENDERER_ALLOW_SOFTWARE
  - Enable SSH with key-based auth only
- Create `hosts/vmware-guest/hardware-configuration.nix` with:
  - VMware initrd modules: ata_piix, mptspi, uhci_hcd, ehci_pci, sd_mod, sr_mod, ahci, nvme
  - VMware kernel modules: vmw_pvscsi
  - Root filesystem on /dev/disk/by-label/nixos (ext4)
  - Boot partition on /dev/disk/by-label/boot (vfat)
  - Swap device on /dev/disk/by-label/swap

### 8. Validate VMware Host Configuration
- **Task ID**: validate-vmware-host
- **Depends On**: create-vmware-host
- **Assigned To**: vmware-host-validator
- **Agent Type**: validator
- **Parallel**: false
- Verify hardware-configuration.nix has correct VMware modules
- Check kernel module blacklist is applied with lib.mkForce
- Confirm VMware guest additions are enabled
- Validate SSH configuration (PasswordAuthentication = false, PermitRootLogin = "no")
- Check all imports resolve correctly
- Verify environment variables for Wayland VM compatibility

### 9. Final Integration and Wiring
- **Task ID**: final-integration
- **Depends On**: validate-vmware-host
- **Assigned To**: integration-engineer
- **Agent Type**: nixos
- **Parallel**: false
- Update flake.nix to import hosts/vmware-guest correctly
- Ensure specialArgs passes all required variables
- Verify module import chain is complete
- Add any missing module connections
- Create treefmt.toml for code formatting
- Add .gitignore with secrets.nix

### 10. Final Validation
- **Task ID**: validate-all
- **Depends On**: final-integration
- **Assigned To**: final-validator
- **Agent Type**: validator
- **Parallel**: false
- Run `nix flake check` to validate flake structure
- Run `nix build .#nixosConfigurations.vmware-guest.config.system.build.toplevel --dry-run` to verify build
- Check all files are properly formatted
- Verify secrets.nix.example contains all required keys
- Confirm all acceptance criteria are met
- Generate validation report

## Acceptance Criteria

1. **Flake Structure**
   - [ ] `flake.nix` exists with nixpkgs, home-manager, hyprland inputs
   - [ ] `nix flake check` passes without errors
   - [ ] Binary caches configured for nix-community and hyprland

2. **Core Modules**
   - [ ] All 10 core modules implemented and importable
   - [ ] VM overrides disable Bluetooth, TLP, power-profiles-daemon
   - [ ] User module integrates Home Manager correctly
   - [ ] Wayland module configures Hyprland and XDG portals

3. **Home Modules**
   - [ ] All essential home modules implemented
   - [ ] VM-specific overrides applied via default.vm.nix
   - [ ] Hyprland configured with VM-compatible settings
   - [ ] Shell (zsh), terminal (ghostty), and git configured

4. **VMware Host**
   - [ ] VMware guest additions enabled
   - [ ] Correct kernel modules loaded (vmw_vsock_vmci_transport, vmw_balloon, vmwgfx)
   - [ ] Intel GPU modules blacklisted
   - [ ] Hardware cursors disabled for Wayland
   - [ ] SSH enabled with secure settings

5. **Build Validation**
   - [ ] `nix build .#nixosConfigurations.vmware-guest.config.system.build.toplevel --dry-run` succeeds
   - [ ] No evaluation errors or missing imports
   - [ ] All module imports resolve correctly

## Validation Commands

Execute these commands to validate the task is complete:

```bash
# Check flake syntax and structure
nix flake check

# Verify flake evaluates without errors
nix flake show

# Dry-run build to check all dependencies resolve
nix build .#nixosConfigurations.vmware-guest.config.system.build.toplevel --dry-run

# Format all Nix files (requires treefmt in devShell)
nix develop -c treefmt --fail-on-change

# Verify secrets template exists
test -f secrets.nix.example && echo "secrets.nix.example exists"

# Check all required directories exist
ls -la modules/core/ modules/home/ hosts/vmware-guest/

# Verify no syntax errors in Nix files
find . -name "*.nix" -exec nix-instantiate --parse {} \; 2>&1 | grep -i error || echo "No syntax errors"
```

## Notes

### Key Patterns from Reference Implementation

**Secrets Access Pattern:**
```nix
# In modules that need secrets
{ customsecrets, ... }:
{
  # Access with fallback
  someApiKey = customsecrets.apiKeys.anthropic or "";
}
```

**VM Override Pattern:**
```nix
# In vm-overrides.nix
{ lib, ... }:
{
  hardware.bluetooth.enable = lib.mkForce false;
  services.tlp.enable = lib.mkForce false;
}
```

**Host-Specific Home Imports:**
```nix
# In user.nix
home-manager.users.${username} = {
  imports = if (host == "nixos-vmware") then
    [ ./../home/default.vm.nix ]
  else
    [ ./../home ];
};
```

**VMware Environment Variables:**
```nix
environment.sessionVariables = {
  WLR_NO_HARDWARE_CURSORS = "1";
  WLR_RENDERER_ALLOW_SOFTWARE = "1";
  LIBVA_DRIVER_NAME = "vmwgfx";
};
```

### Dependencies

This configuration requires:
- NixOS unstable channel
- Hyprland flake input
- Home Manager flake input
- VMware Workstation or Fusion for testing

### Testing Approach

1. First validate flake evaluates: `nix flake check`
2. Then dry-run build: `nix build ... --dry-run`
3. If available, test in actual VMware VM with:
   ```bash
   sudo nixos-rebuild switch --flake .#vmware-guest --impure
   ```
