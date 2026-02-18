# Installation Guide

> [!CAUTION]
> Customizing system configurations may lead to unforeseen effects and potentially disrupt your system's standard operations. Although I've personally tested these settings on my own hardware, they might not perform identically on your specific setup.
> **I cannot assume responsibility for any problems that might result from implementing this configuration.**

> [!WARNING]
> You **must** examine the configuration details and adjust them according to your specific requirements before proceeding with installation.

## Prerequisites

- A fresh NixOS installation (see [Step 1](#1-install-nixos))
- Basic familiarity with the command line
- Git installed or available via `nix-shell`

## 1. Install NixOS

First, install NixOS using an [official ISO image](https://nixos.org/download.html#nixos-iso).

> [!NOTE]
> This was tested with the following parameters:
> - Graphical installer using the official GNOME ISO image
> - `No desktop` or `GNOME` option during installation
> - Intel 13th Gen desktop & mobile hardware
> - VMWare Workstation or Player (v17+) on Microsoft Windows 11

For now, this repository assumes an already installed NixOS system.

## 2. Clone the Repository

```bash
nix-shell -p git
git clone https://github.com/MoshPitCodes/moshpitcodes.nix
cd moshpitcodes.nix
```

## 3. Configure Secrets

> [!IMPORTANT]
> The install script requires `secrets.nix` to be configured before running.

Copy the secrets template and fill in your values:

```bash
cp secrets.nix.example secrets.nix
```

Edit `secrets.nix` to configure:
- **Username and password** - Your system user credentials
- **Git configuration** - Name, email, and GPG signing key
- **Network credentials** - Wi-Fi SSID and password (optional)
- **API keys** - Anthropic, OpenAI for AI-assisted development (optional)
- **SSH key management** - Automatic import from Windows (WSL) or backup locations

Example `secrets.nix` structure:
```nix
{
  username = "yourusername";
  # Generate with: mkpasswd -m sha-512
  hashedPassword = "$6$rounds=...";

  reponame = "moshpitcodes.nix";

  git = {
    userName = "Your Name";
    userEmail = "your.email@example.com";
    user.signingkey = "YOUR_GPG_KEY_ID";  # Optional
  };

  network = {
    wifiSSID = "";      # Optional
    wifiPassword = "";  # Optional
  };

  apiKeys = {
    anthropic = "";  # Optional - for Claude AI
    openai = "";     # Optional - for OpenAI
  };

  sshKeys = {
    sourceDir = "/mnt/c/Users/YourUsername/.ssh";  # WSL example
    keys = [
      "id_ed25519_github"
      "id_ed25519_server"
    ];
  };
}
```

> [!NOTE]
> `secrets.nix` is git-ignored and should **never** be committed to version control.

See [SECRETS.md](../SECRETS.md) for detailed secret management options.

## 4. Run the Install Script

> [!CAUTION]
> For some computers, the default rebuild command might get stuck. To fix that, modify the install script line: `sudo nixos-rebuild switch --flake .#${HOST}` to `sudo nixos-rebuild switch --cores <less than your max number of cores> --flake .#${HOST}`

> [!TIP]
> To ensure you understand what you're executing, review the [Install Script Walkthrough](#install-script-walkthrough) section first.

Before running the install script, configure these key files:
- See [Configuration Guide](configuration.md) for details

When ready, execute (**DO NOT** run as root):
```bash
./install.sh
```

## 5. Reboot

After rebooting, the config should be applied and you should be greeted by hyprlock prompting for your password.

## 6. Manual Configuration

Even though this configuration uses Home Manager, there is still some manual configuration:
- Configure the browser (extensions, account sync, etc.)
- SSH keys are automatically copied from `secrets.nix` during installation
- Some other personal preferences

## Install Script Walkthrough

A brief walkthrough of what the install script does:

### 1. Validate Prerequisites
The script checks for required files: `flake.nix`, `hosts/` directory, and `secrets.nix`.

### 2. Get Username
Reads your username from `secrets.nix`, or prompts you to enter one if not found.

### 3. Update secrets.nix
If you entered a new username, the script updates `secrets.nix` with it.

### 4. Create Basic Directories
The following directories will be created:
- `~/Music`
- `~/Documents`
- `~/Pictures/wallpapers/randomwallpaper`

### 5. Copy the Wallpapers
The wallpapers will be copied into `~/Pictures/wallpapers/`.

### 6. Copy SSH Keys
SSH keys are automatically copied from the `sourceDir` path defined in your `secrets.nix` to `~/.ssh/` with proper permissions.

### 7. Get the Hardware Configuration
Automatically copies the hardware configuration from `/etc/nixos/hardware-configuration.nix` to `./hosts/${host}/hardware-configuration.nix`. This step is skipped for WSL hosts.

### 8. Choose a Host
Select your target host configuration:
- **Desktop** - Full desktop workstation
- **Laptop** - Laptop configuration
- **VM** - QEMU/KVM virtual machine
- **WSL** - Windows Subsystem for Linux
- **VMware** - VMware guest

### 9. Build the System
Runs `nixos-rebuild switch --flake .#<host>` to build and activate the configuration.

## Next Steps

- [Configuration Guide](configuration.md) - Customize your setup
- [WSL Setup](wsl.md) - For Windows integration
- [Development Shells](development-shells.md) - Set up dev environments
