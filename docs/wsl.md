# WSL2 Installation

This configuration includes a WSL2-specific setup optimized for development and DevOps work on Windows.

> [!NOTE]
> The WSL2 configuration is CLI-focused and includes development tools like kubectl, terraform, ansible, Docker/Podman, and more. It does NOT include the desktop environment (Hyprland, Waybar, etc.).

## Prerequisites

### 1. Enable WSL2 on Windows

Open PowerShell as Administrator:
```powershell
wsl --install
```

### 2. Update WSL

If already installed:
```powershell
wsl --update
```

## Installation Steps

### 1. Build the WSL2 Tarball

On your NixOS machine or in a Nix environment:
```bash
# The --impure flag is required to load secrets.nix (git-ignored file)
nix build .#wsl-distro --impure

# Run the builder to generate the tarball
./result/bin/nixos-wsl-tarball-builder
```

> [!IMPORTANT]
> The `--impure` flag is required because `secrets.nix` is git-ignored. Without it, default test credentials will be used instead of your actual secrets.

### 2. Copy the Tarball to Windows

The tarball will be located at `./result/tarball/nixos-wsl-installer.tar.gz`

### 3. Import into WSL2

Open PowerShell on Windows:
```powershell
# Create installation directory
mkdir C:\WSL\NixOS

# Import the distribution
wsl --import NixOS C:\WSL\NixOS .\nixos-wsl-installer.tar.gz
```

### 4. Start NixOS in WSL2

```powershell
wsl -d NixOS
```

### 5. Set as Default (Optional)

```powershell
wsl --set-default NixOS
```

## Features Included

- **CLI Tools**: zsh, neovim, git, tmux, yazi, fzf, and more
- **DevOps Tools**: kubectl, terraform, ansible, helm, k9s, talosctl
- **Cloud Tools**: awscli2, azure-cli
- **Container Tools**: podman with Docker compatibility
- **Development**: Go, Rust, Node.js, Python, Java, TypeScript, Zig
- **SSH Server**: Enabled for remote access
- **VSCode**: Integrated with WSL for development
- **Windows Interop**: Seamless Windows/Linux integration

## Updating WSL Configuration

After making changes to the WSL configuration:

```bash
# Rebuild from within WSL (--impure required for secrets.nix)
sudo nixos-rebuild switch --flake /path/to/repo#wsl --impure

# Or rebuild the tarball and reimport (clean install)
nix build .#wsl-distro --impure

# Or use the rebuild script
./scripts/rebuild.sh wsl
```

## VSCode Remote-WSL Integration

This configuration includes helper tools for managing VSCode extensions declaratively in WSL.

### Install All Declarative Extensions

```bash
vscode-install-extensions
```

### Copy Extensions Recommendations to Your Project

```bash
cp ~/.vscode-remote/extensions.json ~/your-project/.vscode/
```

### Extension Management

- Extensions are defined in `modules/home/vscode-extensions.nix`
- Shared between desktop VSCode and WSL Remote-WSL
- `.vscode-remote/extensions.json` contains recommendations list
- `.vscode-remote/wsl-settings.json` contains WSL-specific settings

This allows you to use Windows VSCode with Remote-WSL extension while maintaining declarative extension management through NixOS.

## Troubleshooting

### Systemd Not Working
Ensure `wsl.nativeSystemd = true` is set (already configured)

### Networking Issues
Check `/etc/wsl.conf` settings

### Windows PATH Integration
Modify `wsl.interop.appendWindowsPath` in config if needed

### Build Failures
Try `./scripts/rebuild.sh wsl --clear-cache` to clear Nix cache
