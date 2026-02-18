# Packaging Sidecar and TD for NixOS

This document provides instructions for creating custom Nix packages for the Sidecar and TD binaries, which are required for the task management workflow but are not yet available in nixpkgs.

## Overview

**Status**: Configuration is ready (`modules/home/sidecar.nix`), but the binaries are not yet packaged.

**Required Packages**:
1. `sidecar` - AI-powered development assistant sidebar
2. `td` - Task-driven development CLI

**Goal**: Create custom package definitions in `pkgs/` directory and wire them into the overlay system.

---

## Step 1: Create Package Definitions

### Sidecar Package

Create `pkgs/sidecar/default.nix`:

```nix
{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
}:

rustPlatform.buildRustPackage rec {
  pname = "sidecar";
  version = "0.1.0"; # Update to latest stable version

  src = fetchFromGitHub {
    owner = "marcus"; # Update to correct GitHub owner
    repo = "sidecar";
    rev = "v${version}";
    sha256 = lib.fakeSha256; # Replace after first build attempt
  };

  cargoSha256 = lib.fakeSha256; # Replace with actual hash after first build

  # Build dependencies
  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  # Run tests during build
  checkPhase = ''
    cargo test --release
  '';

  meta = with lib; {
    description = "AI-powered development assistant sidebar for terminal workflows";
    homepage = "https://github.com/marcus/sidecar"; # Update with actual URL
    changelog = "https://github.com/marcus/sidecar/releases/tag/v${version}";
    license = licenses.mit; # Update based on actual license
    maintainers = [ ]; # Add your maintainer info if desired
    platforms = platforms.linux ++ platforms.darwin;
    mainProgram = "sidecar";
  };
}
```

**Notes**:
- Replace `lib.fakeSha256` with actual hash after first build attempt
- Nix will provide the correct hash in the error message
- Update `owner`, `repo`, and `version` based on actual repository
- Adjust `buildInputs` if additional system libraries are required
- Update `license` field based on project's actual license

---

### TD Package

Create `pkgs/td/default.nix`:

```nix
{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
}:

rustPlatform.buildRustPackage rec {
  pname = "td";
  version = "0.1.0"; # Update to latest stable version

  src = fetchFromGitHub {
    owner = "marcus"; # Update to correct GitHub owner/org
    repo = "td";
    rev = "v${version}";
    sha256 = lib.fakeSha256; # Replace after first build
  };

  cargoSha256 = lib.fakeSha256; # Replace with actual hash

  # Build dependencies
  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  # Run tests during build
  checkPhase = ''
    cargo test --release
  '';

  meta = with lib; {
    description = "Task-driven development CLI for focused, trackable work sessions";
    homepage = "https://github.com/marcus/td"; # Update with actual URL
    changelog = "https://github.com/marcus/td/releases/tag/v${version}";
    license = licenses.mit; # Update based on actual license
    maintainers = [ ];
    platforms = platforms.linux ++ platforms.darwin;
    mainProgram = "td";
  };
}
```

**Notes**:
- Same hash replacement process as sidecar
- Verify the correct GitHub repository URL
- Adjust dependencies based on project requirements

---

## Step 2: Add Packages to Overlay

Edit `overlays/default.nix` to include the new packages:

```nix
final: prev: {
  # Custom packages
  monolisa = final.callPackage ../pkgs/monolisa { };
  reposync = final.callPackage ../pkgs/reposync { };

  # Task management tools (NEW)
  sidecar = final.callPackage ../pkgs/sidecar { };
  td = final.callPackage ../pkgs/td { };
}
```

---

## Step 3: Update sidecar.nix Module

Once packages are defined, uncomment the package references in `modules/home/sidecar.nix`:

```nix
{
  lib,
  pkgs,
  config,
  ...
}:
# ... (config definition omitted for brevity)
{
  # Install sidecar and td packages
  home.packages = with pkgs; [
    sidecar  # Uncomment after packaging
    td       # Uncomment after packaging

    # Dependencies for sidecar/td scripts
    jq
    fzf
    tmux
  ];

  # ... (rest of configuration)
}
```

**Current State**: The `sidecar` and `td` package references are commented out until the packages are built.

**After Packaging**: Remove the comments to enable installation.

---

## Step 4: Build and Test

### Initial Build (to get hashes)

```bash
# Try building sidecar package
nix build .#sidecar

# Nix will fail with hash mismatch error like:
# error: hash mismatch in fixed-output derivation '/nix/store/...':
#   specified: sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=
#   got:       sha256-abc123xyz789...=

# Copy the "got" hash into pkgs/sidecar/default.nix (replacing lib.fakeSha256)
```

Repeat for `td` package:

```bash
nix build .#td
# Copy the correct hash into pkgs/td/default.nix
```

### Full System Build

After updating hashes:

```bash
# Build full system configuration
nix build .#nixosConfigurations.vmware-guest.config.system.build.toplevel

# If successful, rebuild the system
sudo nixos-rebuild switch --flake .#vmware-guest
```

### Verify Installation

After rebuild:

```bash
# Check if binaries are in PATH
which sidecar
which td

# Test basic functionality
sidecar --version
td --version

# Test zsh aliases (should work now)
sc --help
tdi
```

---

## Step 5: Test Integration

### Test Sidecar Configuration

```bash
# Check default config was created
cat ~/.config/sidecar/config.json

# Launch sidecar
sidecar-dashboard

# Test tmux integration
cd ~/Development/shifttab.nix
sidecar-split
```

### Test TD Workflow

```bash
# Initialize TD in project
cd ~/Development/shifttab.nix
td-init-project

# Create a test task
tdc "Test task for validation"

# Start the task
tds TEST-1

# Check status
tdi

# Log entry
tdl "Validated TD integration"

# Complete task
tda TEST-1
```

---

## Alternative: Manual Installation (Temporary)

If packaging is taking longer than expected, you can manually install the binaries as a temporary workaround:

```bash
# Download or build sidecar/td manually
cargo install --git https://github.com/marcus/sidecar # Update URL
cargo install --git https://github.com/marcus/td     # Update URL

# Binaries will be in ~/.cargo/bin/
# Sidecar config will still work via the module
```

**Note**: This bypasses Nix package management and won't be declarative. Use only for testing.

---

## Troubleshooting

### Build Dependency Issues

If the build fails due to missing dependencies:

1. **Check Cargo.toml** in the upstream repository for dependencies
2. **Add to buildInputs** in the Nix package definition
3. Common dependencies:
   - `openssl` (crypto operations)
   - `sqlite` (database operations)
   - `libgit2` (git integration)
   - `libssh2` (SSH operations)

Example:
```nix
buildInputs = [
  openssl
  sqlite
  libgit2
  libssh2
];
```

### Hash Mismatch During Updates

When updating versions:

1. Update `version` field
2. Update `rev` field (usually `"v${version}"`)
3. Set `sha256 = lib.fakeSha256;` temporarily
4. Run build to get new hash
5. Replace with correct hash from error message
6. Set `cargoSha256 = lib.fakeSha256;` temporarily
7. Run build again to get cargo hash
8. Replace with correct hash

### Package Not Found After Overlay

If `nix build .#sidecar` fails with "package not found":

1. Verify overlay is imported in `flake.nix`:
   ```nix
   overlays = [
     (import ./overlays)
   ];
   ```

2. Check package callable in `overlays/default.nix`:
   ```nix
   sidecar = final.callPackage ../pkgs/sidecar { };
   ```

3. Rebuild flake lock:
   ```bash
   nix flake update
   ```

---

## Example Directory Structure

After completing packaging:

```
shifttab.nix/
├── pkgs/
│   ├── monolisa/          # Existing custom package
│   ├── reposync/          # Existing custom package
│   ├── sidecar/           # NEW
│   │   └── default.nix
│   └── td/                # NEW
│       └── default.nix
├── overlays/
│   └── default.nix        # Updated with sidecar and td
└── modules/home/
    └── sidecar.nix        # Uncomment package references
```

---

## Resources

### Nix Packaging Documentation

- [Nixpkgs Manual - Rust](https://nixos.org/manual/nixpkgs/stable/#rust)
- [Nixpkgs Manual - buildRustPackage](https://nixos.org/manual/nixpkgs/stable/#buildrustpackage)
- [Nix Pills - Packaging](https://nixos.org/guides/nix-pills/fundamentals-of-stdenv.html)

### Sidecar and TD Projects

- Sidecar Repository: [Update with actual URL]
- TD Repository: [Update with actual URL]
- Installation guides in their respective README files

### Similar Package Examples

Look at existing Rust packages in nixpkgs for reference:

```bash
# Find Rust package examples
nix-locate buildRustPackage | grep default.nix | head -20
```

---

## Next Steps

1. **Research repositories**: Find the correct GitHub URLs for sidecar and td
2. **Determine versions**: Check latest stable releases
3. **Create package files**: Follow templates above
4. **Build and test**: Get hashes and verify functionality
5. **Update sidecar.nix**: Uncomment package references
6. **Rebuild system**: Apply changes system-wide
7. **Validate workflow**: Test all aliases and functions

---

**Status**: ⚠️ Pending - Packages not yet created
**Priority**: Medium - Configuration is ready, workflows depend on these binaries
**Estimated Effort**: 2-4 hours (including testing and troubleshooting)

---

**Last Updated**: 2026-02-15
**Maintained By**: moshpitcodes
