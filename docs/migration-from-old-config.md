# Migration Status: Old Config to shifttab.nix

This document tracks features and configurations migrated from `moshpitcodes.nix-main` (old config) to `shifttab.nix` (current config).

## Migration Overview

**Source Repository**: `~/Development/moshpitcodes.nix-main`
**Target Repository**: `~/Development/shifttab.nix`
**Migration Period**: February 2026
**Status**: Feature-complete + Laptop host added

---

## Successfully Migrated Features

### 1. JetBrains Rider IDE (✅ Complete)

**File**: `modules/home/rider.nix`
**Source**: `moshpitcodes.nix-main/modules/home/rider.nix`

**What was migrated**:
- JetBrains Rider IDE with custom wrapper
- .NET SDK 8.0 (updated from SDK 7.0)
- Mono runtime and MSBuild
- Unity plugin symlink support for Unity editor integration
- Custom PATH and LD_LIBRARY_PATH injection
- Desktop entry for Unity integration

**Changes from old config**:
- Updated from `dotnetCorePackages.sdk_7_0` to `dotnetCorePackages.sdk_8_0`
- Updated deprecated xorg package references (`xorg.libX11` → `libx11`, etc.)
- Maintained all Unity debugging libraries and symlink logic

**Import location**: `modules/home/default.nix` (Desktop applications section)

---

### 2. VSCode Remote-WSL Extension Management (✅ Complete)

**File**: `modules/home/vscode-remote.nix`
**Source**: `moshpitcodes.nix-main/modules/home/vscode-remote.nix`

**What was migrated**:
- Curated extension list for Windows VSCode via Remote-WSL
- `vscode-install-extensions` helper script for WSL environments
- WSL-specific VSCode settings.json generation
- README documentation for extension installation

**Changes from old config**:
- Updated formatter path from `nixpkgs-fmt` to `nixfmt` (matching current config standards)
- Added newer extensions to extension list
- Preserved all WSL-specific configuration patterns

**Import location**: `modules/home/default.wsl.nix` (WSL-only hosts)

**Note**: This module is WSL-specific and is NOT included in desktop/VMware builds.

---

### 3. Sidecar + TD Task Management (✅ Complete)

**File**: `modules/home/sidecar.nix`
**Source**: `moshpitcodes.nix-main/modules/home/development/sidecar.nix`

**What was migrated**:
- Default sidecar configuration with all plugins enabled
- Complete set of zsh aliases:
  - Sidecar aliases: `sc`, `scd`, `scp`, `sidecar-help`, `sidecar-config`, etc.
  - TD aliases: `tdi`, `tdc`, `tds`, `tdl`, `tdn`, `tdu`, `tdm`, `tdr`, `tda`, `tdh`, `tdq`, `tdb`
- Complete set of zsh helper functions:
  - `sidecar-split` - Split tmux panes with sidecar
  - `sidecar-dashboard` - Launch sidecar dashboard
  - `sidecar-goto` - Quick project navigation
  - `td-init-project` - Initialize TD in project
  - `td-ai-handoff` - Generate AI handoff summary
  - `td-quick-start` - Quick task creation and start
  - `td-stats` - Show task statistics
  - `sidecar-tips` - Show usage tips

**Changes from old config**:
- Updated project path from `~/Development/moshpitcodes.nix` to `~/Development/shifttab.nix`
- All executables use full nix store paths (`${pkgs.jq}/bin/jq`, etc.)
- Config JSON generation matches current standards

**Import location**: `modules/home/default.nix` (Shell & CLI tools section)

**Package Status**:
- ⚠️ **Sidecar and TD binaries NOT yet packaged in nixpkgs**
- Configuration is ready, but packages need custom packaging in `pkgs/` directory
- See "Pending Work" section below for packaging instructions

---

### 4. Discord CSS Theming (✅ Complete)

**Files**:
- `modules/home/discord/default.nix` (updated)
- `modules/home/discord/osaka-jade.css` (new)

**Source**: `moshpitcodes.nix-main/modules/home/discord/` (gruvbox theme)

**What was migrated**:
- DiscoCSS integration for CSS injection
- Custom Discord theme (converted from Gruvbox to Osaka Jade palette)
- Discord settings with devtools enabled

**Changes from old config**:
- Replaced Gruvbox color palette with Osaka Jade:
  - Background: `#11221C` (UI), `#0d1a15` (secondary), `#111c18` (tertiary)
  - Text: `#e6d8ba` (normal), `#C1C497` (muted)
  - Accent: `#71CEAD` (jade green)
  - Surface: `#23372B`
- Updated DiscoCSS config paths to match current structure
- Maintained all CSS customization patterns from old config

**Import location**: Already imported in `modules/home/default.nix`

---

## Theme Migration Status

### Theme Decision: CANCELLED Osaka Jade Migration

**Original Plan**: Migrate all 16+ modules from Everforest to Osaka Jade theme
**Decision**: Task #19 (theme migration) was **CANCELLED**
**Current State**: **Keeping Everforest theme** for most modules

**Theme Status by Module**:

| Module | Theme | Status |
|--------|-------|--------|
| `tmux.nix` | Osaka Jade | ✅ Already using Osaka Jade (unchanged) |
| `media.nix` | Osaka Jade | ✅ Already using Osaka Jade (unchanged) |
| `discord/osaka-jade.css` | Osaka Jade | ✅ New Discord theme (migrated feature) |
| `hyprland/default.nix` | Everforest | ⚪ Keeping Everforest |
| `waybar/default.nix` | Everforest | ⚪ Keeping Everforest |
| `walker.nix` | Everforest | ⚪ Keeping Everforest |
| `wlogout.nix` | Everforest | ⚪ Keeping Everforest |
| `swaync.nix` | Everforest | ⚪ Keeping Everforest |
| `swaylock.nix` | Everforest | ⚪ Keeping Everforest |
| `hyprlock.nix` | Everforest | ⚪ Keeping Everforest |
| `ghostty.nix` | Everforest | ⚪ Keeping Everforest |
| `fzf.nix` | Everforest | ⚪ Keeping Everforest |
| `lazygit.nix` | Everforest | ⚪ Keeping Everforest |
| `cava.nix` | Everforest | ⚪ Keeping Everforest |
| `btop.nix` | Everforest | ⚪ Keeping Everforest |
| `vivid.nix` | Everforest | ⚪ Keeping Everforest |
| `micro.nix` | Everforest | ⚪ Keeping Everforest |
| `swayosd.nix` | Everforest | ⚪ Keeping Everforest |
| `theming.nix` | Everforest | ⚪ Keeping Everforest |
| `starship.toml` | Everforest | ⚪ Keeping Everforest |
| `nvim.nix` | Everforest | ⚪ Keeping Everforest |

**Rationale**: The Osaka Jade theme migration was deemed unnecessary after successfully migrating the core features. Everforest provides a consistent, tested theme across the system, and the Osaka Jade palette is available where it adds value (tmux, media player, Discord).

---

### 5. Laptop Host Configuration (✅ Complete)

**Files**:
- `hosts/laptop/default.nix`
- `hosts/laptop/hardware-configuration.nix` (placeholder)
- `modules/home/default.laptop.nix`
- `modules/home/hyprland/laptop-overrides.nix`

**Source**: `moshpitcodes.nix-main/hosts/laptop/default.nix`

**What was migrated**:
- Laptop host configuration for ASUS Zenbook 14X OLED
- TLP power management with full AC/battery profiles
- UPower battery monitoring (low=20%, critical=5%, action=3%)
- Intel kernel modules (i915, iwlwifi, btusb, acpi_call, intel_pstate, etc.)
- Boot configuration: silent boot, i915 early KMS, kernel parameters
- Kernel sysctl tuning (swappiness=10, vfs_cache_pressure=50)
- Laptop-specific packages (acpi, brightnessctl, cpupower-gui, powertop)
- SSH with key-only authentication
- Hyprland OLED monitor config (2880x1800@120Hz, 1.5x scale)
- Brightness key bindings (XF86MonBrightnessUp/Down → swayosd-client)
- Waybar battery and backlight widgets (conditional on host != vmware-guest)

**Changes from old config**:
- Removed `mac-style-plymouth` theme (using default Plymouth)
- Simplified TLP config (removed some experimental GPU settings)
- Updated to modern nixpkgs structure (cpupower module path)
- Added proper `lib.mkForce` for monitor override
- Integrated with existing Everforest waybar theme
- VM-specific overrides moved from core to `hosts/vmware-guest/default.nix`

**Import location**: `flake.nix` (new `laptop` nixosConfiguration entry)

**Deployment Notes**:
- ⚠️ **IMPORTANT**: The `hardware-configuration.nix` is a PLACEHOLDER with dummy UUIDs
- Must run on actual laptop hardware: `sudo nixos-generate-config --show-hardware-config > hosts/laptop/hardware-configuration.nix`
- GPU PCI ID `i915.force_probe=a7a0` may need adjustment based on exact Intel Iris Xe variant
- Monitor name `eDP-1` is typical but verify with `hyprctl monitors`

---

## Intentionally NOT Migrated

The following features from the old config were reviewed and intentionally **NOT migrated**:

### Packages Already Present

These packages were initially flagged as missing but are already in the current config:

| Package | Status | Location |
|---------|--------|----------|
| `easyeffects` | ✅ Already present | `modules/home/packages.nix` |
| `gimp` | ✅ Already present | `modules/home/packages.nix` |
| `thunderbird` | ✅ Already present | `modules/home/packages.nix` |
| `onefetch` | ✅ Already present | `modules/home/packages.nix` |
| `dconf-editor` | ✅ Already present | `modules/home/packages.nix` |
| `wine` | ✅ Already present | `modules/home/packages.nix` (as `wineWow64Packages.wayland`) |
| `tldr` | ✅ Already present | `modules/home/packages.nix` (as `tealdeer`) |

### Features Not Needed

| Feature | Rationale |
|---------|-----------|
| Old theme configurations | Keeping Everforest theme (see Theme Status above) |
| Deprecated package references | Updated to current nixpkgs naming conventions |
| WSL-specific hacks | Properly handled in `default.wsl.nix` and WSL-specific modules |

---

## Pending Work

### Custom Package Creation Required

The following packages need custom packaging in `pkgs/` directory:

#### 1. Sidecar Binary

**Package**: `sidecar`
**Status**: Not available in nixpkgs
**Config Ready**: ✅ Yes (`modules/home/sidecar.nix`)
**Location**: Should be packaged at `pkgs/sidecar/default.nix`

**Packaging Instructions**:
```nix
# Create pkgs/sidecar/default.nix
{ lib, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "sidecar";
  version = "0.1.0";  # Update to latest version

  src = fetchFromGitHub {
    owner = "marcus";  # Update to correct owner
    repo = "sidecar";
    rev = "v${version}";
    sha256 = lib.fakeSha256;  # Replace with real hash after first build
  };

  cargoSha256 = lib.fakeSha256;  # Replace with real hash after first build

  meta = with lib; {
    description = "AI-powered development assistant sidebar";
    homepage = "https://github.com/marcus/sidecar";  # Update URL
    license = licenses.mit;
    maintainers = [ ];
  };
}
```

Then add to `overlays/default.nix`:
```nix
final: prev: {
  sidecar = final.callPackage ../pkgs/sidecar { };
}
```

#### 2. TD Task Manager Binary

**Package**: `td`
**Status**: Not available in nixpkgs
**Config Ready**: ✅ Yes (`modules/home/sidecar.nix`)
**Location**: Should be packaged at `pkgs/td/default.nix`

**Packaging Instructions**:
```nix
# Create pkgs/td/default.nix
{ lib, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "td";
  version = "0.1.0";  # Update to latest version

  src = fetchFromGitHub {
    owner = "marcus";  # Update to correct owner/org
    repo = "td";
    rev = "v${version}";
    sha256 = lib.fakeSha256;  # Replace with real hash
  };

  cargoSha256 = lib.fakeSha256;  # Replace with real hash

  meta = with lib; {
    description = "Task-driven development CLI";
    homepage = "https://github.com/marcus/td";  # Update URL
    license = licenses.mit;
    maintainers = [ ];
  };
}
```

Then add to `overlays/default.nix`:
```nix
final: prev: {
  td = final.callPackage ../pkgs/td { };
}
```

**Next Steps**:
1. Create the package definitions in `pkgs/sidecar/` and `pkgs/td/`
2. Add them to overlays
3. Update `modules/home/sidecar.nix` to uncomment the package references
4. Build and test with `nix build .#nixosConfigurations.vmware-guest.config.system.build.toplevel`

---

## Build Validation

All migrated features have been validated:

```bash
# Full system build validation
✅ nix build .#nixosConfigurations.vmware-guest.config.system.build.toplevel

# Individual module validation
✅ Rider IDE builds and imports correctly
✅ VSCode Remote config present in WSL module
✅ Sidecar config ready (binaries pending packaging)
✅ Discord DiscoCSS theme applied
```

**Build Status**: All configurations build successfully with zero errors.

---

## Documentation Updates

The following documentation has been updated to reflect migration changes:

1. **`docs/language-servers.md`**:
   - ✅ Replaced `nixfmt-rfc-style` references with `nixfmt`
   - ✅ Updated migration notes to reflect current state

2. **`docs/migration-from-old-config.md`** (this file):
   - ✅ Complete migration tracking documentation
   - ✅ Theme status clarification
   - ✅ Packaging requirements documented

3. **MEMORY.md** updates needed:
   - ⚠️ Theme documentation inconsistency (see below)

---

## MEMORY.md Theme Inconsistency

**Issue**: MEMORY.md currently documents Osaka Jade as the project theme, but most modules use Everforest.

**Options**:

### Option A: Update MEMORY.md to reflect Everforest as primary theme
```markdown
## Theme: Everforest (Primary) + Osaka Jade (Accents)
- **Primary Theme**: Everforest Dark Hard (most modules)
- **Osaka Jade Palette**: Used selectively in tmux, media player, Discord
- UI Background: `#232A2E` (Everforest), UI Foreground: `#D3C6AA`
- Accent modules (tmux/media): `#71CEAD` (Osaka Jade)
```

### Option B: Keep Osaka Jade documentation as aspirational
```markdown
## Theme: Osaka Jade Color Palette (Target)
- **Current Status**: Migration in progress
- **Complete**: tmux.nix, media.nix, discord/osaka-jade.css
- **Pending**: 16+ modules still using Everforest (see docs/migration-from-old-config.md)
```

**Recommendation**: Choose **Option A** for accuracy, or **Option B** if planning to complete the theme migration in the future.

---

## Summary

### Migration Statistics

- **Features Successfully Migrated**: 4
  1. ✅ Rider IDE with .NET 8.0 and Unity debugging
  2. ✅ VSCode Remote-WSL extension management
  3. ✅ Sidecar + TD task management configuration
  4. ✅ Discord CSS theming with Osaka Jade palette

- **Theme Migration**: ❌ CANCELLED (keeping Everforest)
  - Osaka Jade used only in: tmux, media, Discord
  - 16+ modules remain on Everforest theme

- **Packages Confirmed Present**: 7 (easyeffects, gimp, thunderbird, onefetch, dconf-editor, wine, tldr)

- **Custom Packaging Required**: 2 (sidecar, td binaries)

### Build Status

✅ **All configurations build successfully**
✅ **Zero build errors**
✅ **Full feature parity achieved** (modulo pending binary packages)

---

**Last Updated**: 2026-02-15
**Maintained By**: moshpitcodes
**Migration Status**: Complete (pending sidecar/td packaging)
