<h1 align="center">
   <img src="./.github/assets/logo/nixos-logo.png  " width="100px" />
   <br>
      My NixOS Configuration
   <br>
      <img src="./.github/assets/pallet/pallet-0.png" width="800px" /> <br>

   <div align="center">
      <p></p>
      <div align="center">
         <a href="https://github.com/MoshPitCodes/moshpitcodes.nix/stargazers">
            <img src="https://img.shields.io/github/stars/MoshPitCodes/moshpitcodes.nix?color=FABD2F&labelColor=282828&style=for-the-badge&logo=starship&logoColor=FABD2F">
         </a>
         <a href="https://github.com/MoshPitCodes/moshpitcodes.nix/">
            <img src="https://img.shields.io/github/repo-size/MoshPitCodes/moshpitcodes.nix?color=B16286&labelColor=282828&style=for-the-badge&logo=github&logoColor=B16286">
         </a>
         <a href="https://nixos.org">
            <img src="https://img.shields.io/badge/NixOS-unstable-blue.svg?style=for-the-badge&labelColor=282828&logo=NixOS&logoColor=458588&color=458588">
         </a>
         <a href="https://github.com/MoshPitCodes/moshpitcodes.nix/blob/main/LICENSE">
            <img src="https://img.shields.io/static/v1.svg?style=for-the-badge&label=License&message=MIT&colorA=282828&colorB=98971A&logo=unlicense&logoColor=98971A&"/>
         </a>
      </div>
      <br>
   </div>
   <div>
      <a href="https://github.com/MoshPitCodes/moshpitcodes.nix/actions/workflows/test-flake.yml">
         <img src="https://img.shields.io/github/actions/workflow/status/MoshPitCodes/moshpitcodes.nix/test-flake.yml?branch=main&style=for-the-badge&labelColor=282828&logo=github&logoColor=D79921&color=D79921&label=Flake">
      </a>
      <a href="https://github.com/MoshPitCodes/moshpitcodes.nix/actions/workflows/test-configurations.yml">
         <img src="https://img.shields.io/github/actions/workflow/status/MoshPitCodes/moshpitcodes.nix/test-configurations.yml?branch=main&style=for-the-badge&labelColor=282828&logo=github&logoColor=FB4934&color=FB4934&label=Configs">
      </a>
   </div>
</h1>
<br/>

# 🗃️ Overview

Hi,

My name is Mosh and this is my personal NixOS system configuration. This is something I have been working on over the past couple of months while learning NixOS and slowly transitioning from Windows to NixOS for all my development work. I am using this as my daily driver on an ASUS Zenbook 14X OLED now with the following hardware:

- Intel Core i9 13900H
- Intel XE Graphics
- 16GB DDR-5 RAM
- 3 external monitors
- USB Hub, docking station and peripherals like webcam, DAC, and more

Additionally, I'm using this on a desktop machine as a dual boot system for when I feel like it:
- Intel Core i7 13700K
- Nvidia RTX 4070Ti Super
- 64GB DDR-5 RAM
- 3 external monitors
- USB Hub, docking station and peripherals like webcam, DAC, and more

> [!WARNING]
> This is a heavily opinionated configuration that is likely not a great repository if you're just starting out with Linux or if you're trying to learn what NixOS is all about. The approach to building a modular, reusable and reproducible environment might not even align with best practices since I am not a NixOS expert by any stretch of the imagination. This is a personal project that is based on my experience in the NixOS ecosystem, information from the community and the wonderful open-source creators in the NixOS space. The setup is tailored to my specific needs and wants and will likely not provide a great baseline for you to build off of. Even though there are things packaged like the Steam client for gaming, this configuration is mainly used by myself as a proving ground and learning opportunity. Do not expect anything else.

And now, let the fun begin!

<br/>

## 📚 Project Structure

-   [./flake.nix](flake.nix) Entry point to the configuration
-   [./hosts/](hosts) 🌳 Per-host configurations that contain machine specific setups
    - [../desktop/](hosts/desktop/) 🖥️ Specific configuration for desktop machines
    - [../laptop/](hosts/laptop/) 💻 Specific configuration for laptops
    - [../vm/](hosts/vm/) 🗄️ QEMU/KVM specific configuration (WIP)
    - [../vmware-guest/](hosts/vmware-guest/) 🗄️ VMWare Workstation/Player specific configuration (WIP)
    - [../wsl/](hosts/wsl/) 🪟 WSL2 specific configuration for Windows development
-   [./modules/](modules) 🍱 Modularized NixOS configurations
    -   [../core/](modules/core/) ⚙️ Core NixOS configuration
    -   [../home/](modules/home/) 🏠 my [Home Manager](https://github.com/nix-community/home-manager) config
-   [./shells/](shells) 🧪 Development shell environments (claude-flow, etc.)
-   [./secrets.nix](secrets.nix.example) 🔐 Secrets management (git-ignored, use secrets.nix.example as template)
-   [./pkgs](flake/pkgs) 📦 Packages built from source
-   [./wallpapers](wallpapers/) 🌄 Wallpapers collection

<br/>

>[!TIP]
> If you open this ```README.md``` file in [VSCode][VSCode] or [VSCodium][VSCodium], you can ```Ctrl + LMB``` the links above. This will take you to the files in the editor.
> <br/>
> Recommended VSCode extension (pre-configured in this project): [Markdown All-in-One](https://marketplace.visualstudio.com/items?itemName=yzhang.markdown-all-in-one)

<br/>

## 📓 Project Components
| Use Case                    | Software                                                                            |
| --------------------------- | :---------------------------------------------------------------------------------- |
| **Display Server Protocol** | [Wayland][Wayland]                                                                  |
| **Window Manager**          | [Hyprland][Hyprland]                                                                |
| **Wallpaper Manager**       | [Waypaper][Waypaper] + [Hyprpaper][Hyprpaper]                                       |
| **Information Bar**         | [Waybar][Waybar]                                                                    |
| **Application Launcher**    | [rofi][rofi]                                                                        |
| **Notification Daemon**     | [swaync][swaync]                                                                    |
| **Terminal Emulator**       | [Ghostty][Ghostty]                                                                  |
| **Shell**                   | [zsh][zsh] + [powerlevel10k][powerlevel10k]                                         |
| **Text Editor**             | [VSCodium][VSCodium] + [VSCode][VSCode] + [Neovim][Neovim]                          |
| **AI Editor**               | [CursorAI][CursorAI]                                                                |
| **Network Management Tool** | [NetworkManager][NetworkManager] + [network-manager-applet][network-manager-applet] |
| **System Resource Monitor** | [Btop][Btop]                                                                        |
| **File Manager**            | [nemo][nemo] + [yazi][yazi]                                                         |
| **Fonts**                   | [Maple Mono][Maple Mono]                                                            |
| **Color Scheme**            | [Gruvbox Dark Hard][Gruvbox]                                                        |
| **GTK Theme**               | [Colloid GTK Theme][Colloid GTK Theme]                                              |
| **Mouse Cursor Theme**      | [Bibata-Modern-Ice][Bibata-Modern-Ice]                                              |
| **Icon Theme**              | [Papirus-Dark][Papirus-Dark]                                                        |
| **Lockscreen**              | [Hyprlock][Hyprlock] + [Swaylock-effects][Swaylock-effects]                         |
| **Image Viewer**            | [imv][imv]                                                                          |
| **Screenshot Tool**         | [grimblast][grimblast]                                                              |
| **Screen Recording Tool**   | [wf-recorder][wf-recorder] + [OBS][OBS]                                             |
| **Media Player**            | [mpv][mpv]                                                                          |
| **Music Player**            | [audacious][audacious]                                                              |
| **Clipboard Management**    | [wl-clip-persist][wl-clip-persist]                                                  |
| **Color Picker**            | [hyprpicker][hyprpicker]                                                            |
| **DevOps Tools**            | several tools like k8s, Docker, etc.                                                |


<br/>
<br/>

# 🚀 Installation

> [!CAUTION]
> Customizing system configurations, particularly those affecting operating systems, may lead to unforeseen effects and potentially disrupt your system's standard operations. Although I've personally tested these settings on my own hardware, they might not perform identically on your specific setup.
> **I cannot assume responsibility for any problems that might result from implementing this configuration.**

> [!WARNING]
> You **must** examine the configuration details and adjust them according to your specific requirements before proceeding with installation.

<br/>

## 1. **Install NixOS**

First, install NixOS using an [official ISO image](https://nixos.org/download.html#nixos-iso).
> [!NOTE]
> This was tested with the following parameters:
> - Graphical installer using the official GNOME ISO image
> - ```No desktop``` or ```GNOME``` option during installation
> - Intel 13th Gen desktop & mobile hardware (especially relevant regarding drivers!)
> - VMWare Workstation or Player (v17+) on Microsoft Windows 11

For now, this repository assumes an already installed NixOS system. I might end up putting this into configurable scripts specifically for remote installation on baremetal or virtual hosts. This is a nice-to-have for me currently and will not happen until I have the need to do so and the time to refactor a lot of stuff for my homelab.
<br/>

## 2. **Clone the repository**

```bash
nix-shell -p git
git clone https://github.com/MoshPitCodes/moshpitcodes.nix
cd moshpitcodes.nix
```

<br/>

## 2.5. **Configure Secrets**

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
  password = "yourpassword";

  git = {
    userName = "Your Name";
    userEmail = "your.email@example.com";
    user.signingkey = "YOUR_GPG_KEY_ID";
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
> `secrets.nix` is git-ignored and should **never** be committed to version control. This file contains sensitive credentials.

<br/>

## 3. **Install script**
> [!CAUTION]
> For some computers, the default rebuild command might get stuck. To fix that modify the install script line: ```sudo nixos-rebuild switch --flake .#${HOST}``` to ```sudo nixos-rebuild switch --cores <less than your max number of cores> --flake .#${HOST}```

> [!TIP]
> To ensure you understand what you're executing, it's advisable to review the script's contents or at minimum consult the [Install script walkthrough](#Install-script-walkthrough) section prior to running it.

For initial installation, using the install script is recommended. However, before executing this script, you should properly configure your NixOS installation. Begin by examining these key files:

### Configure monitors
Files:
```./modules/home/hyprland/config.nix```

Run ```hyprctl monitors all``` to check for the identifiers / names of your monitors.

<br/>

### Configure wallpapers
Files:
```./modules/home/waypaper.nix```
```./modules/home/hyprland/hyprpaper.nix```
```./modules/home/hyprland/hyprlock.nix```

<br/>

### Configure the Wi-Fi connection
Files:
```./modules/home/network.nix```

```nix
{
   wireless.networks = {
      "<SSID>" = { # replace with actual SSID
         psk = throw "<Enter Wi-Fi password in ./modules/core/network.nix>"; # replace with actual password
      };
   };
}
```
<br/>

### Configure the Git account information

> [!TIP]
> Git configuration is now automated via `secrets.nix`. The install script reads your git settings from the secrets file.

If you need to manually configure Git, edit:
```./modules/home/git.nix```

```nix
{
   programs.git = {
      # Rest of the configuration

      # Remove 'throw' keyword, keep quotes
      userName = throw "<Enter user.name in ./modules/home/git.nix)>";
      userEmail = throw "<Enter user.mail in ./modules/home/git.nix)>";

      # Rest of the configuration
   };
}
```

<br/>

### Configure default username

> [!TIP]
> Username is now configured in `secrets.nix`. The install script reads your username from the secrets file and uses it automatically.

If you need to manually configure the username fallback in the install script:
Files: ```./install.sh```

```bash
init() {
    # Vars
    CURRENT_USERNAME='<username>'

    # rest of the configuration
}
```
<br/>

### Configure VSCode Extensions
Files:
```./modules/home/vscode.nix```

```nix
{
   # rest of the configuration

   profiles.default = {
      extensions = with pkgs.vscode-extensions; [
         # nix language
         jnoortheen.nix-ide

         # add more VSCode extensions
      ];
   };
}
```

<br/>

### Set Aseprite Theme
Files:
```./modules/home/aseprite/themes```

<br/>

### Configure Audacious
Files: ```./modules/home/audacious.nix```

Change the directory for the Music folder, replace ```<username>``` with your username.
```text
[audgui]
filesel_path=/home/<username>/Music
```

<br/>

When you're happy with your configuration, execute and follow the installation script (**DO NOT** run as root)
```bash
./install.sh
```

<br/>

## 4. **Reboot**

After rebooting, the config should be applied and you should be greeted by hyprlock prompting for your password.

<br/>

## 5. **Manual configuration**

Even though this configuration uses Home Manager, there is still a little bit of manual configuration to do after the installation is completed:
- Configure the browser (e.g. extensions, account sync, etc.)
- SSH keys are automatically copied from `secrets.nix` configuration during installation
- Some other personal preferences, just dig around and see what you can find

<br/>

## 6. **WSL2 Installation** 🪟

This configuration includes a WSL2-specific setup optimized for development and DevOps work on Windows.

> [!NOTE]
> The WSL2 configuration is CLI-focused and includes development tools like kubectl, terraform, ansible, Docker/Podman, and more. It does NOT include the desktop environment (Hyprland, Waybar, etc.).

### Prerequisites

1. **Enable WSL2 on Windows** (PowerShell as Administrator):
   ```powershell
   wsl --install
   ```

2. **Update WSL** (if already installed):
   ```powershell
   wsl --update
   ```

### Installation Steps

1. **Build the WSL2 tarball**:
   ```bash
   # On your NixOS machine or in a Nix environment
   # Step 1a: Build the tarball builder
   nix build .#packages.x86_64-linux.wsl-distro

   # Step 1b: Run the builder to generate the tarball
   ./result/bin/nixos-wsl-tarball-builder
   ```

2. **Copy the tarball to Windows**:
   The tarball will be located at `./result/tarball/nixos-wsl-installer.tar.gz`

3. **Import into WSL2** (PowerShell on Windows):
   ```powershell
   # Create installation directory
   mkdir C:\WSL\NixOS

   # Import the distribution
   wsl --import NixOS C:\WSL\NixOS .\nixos-wsl-installer.tar.gz
   ```

4. **Start NixOS in WSL2**:
   ```powershell
   wsl -d NixOS
   ```

5. **Set as default** (optional):
   ```powershell
   wsl --set-default NixOS
   ```

### Features Included

- **CLI Tools**: zsh, neovim, git, tmux, yazi, fzf, and more
- **DevOps Tools**: kubectl, terraform, ansible, helm, k9s, talosctl
- **Cloud Tools**: awscli2, azure-cli
- **Container Tools**: podman with Docker compatibility
- **Development**: Go, Rust, Node.js, Python, Java, TypeScript, Zig
- **SSH Server**: Enabled for remote access
- **VSCode**: Integrated with WSL for development
- **Windows Interop**: Seamless Windows/Linux integration

### Updating WSL Configuration

After making changes to the WSL configuration:

```bash
# Rebuild from within WSL
sudo nixos-rebuild switch --flake /path/to/repo#wsl

# Or rebuild the tarball and reimport (clean install)
```

### Troubleshooting

- **Systemd not working**: Ensure `wsl.nativeSystemd = true` is set (already configured)
- **Networking issues**: Check `/etc/wsl.conf` settings
- **Windows PATH integration**: Modify `wsl.interop.appendWindowsPath` in config if needed

<br/>

## A. Install script walkthrough

A brief walkthrough of what the install script does.

#### 1. **Get username**

You will receive a prompt to enter your username with a confirmation check.

#### 2. **Set username**

The script will replace all occurances of the default usename ```CURRENT_USERNAME``` by the given one stored in ```$username```

#### 3. Create basic directories

The following directories will be created:
- ```~/Music```
- ```~/Documents```
- ```~/Pictures/wallpapers/randomwallpaper```

#### 4. Copy the wallpapers

The wallpapers will be copied into ```~/Pictures/wallpapers/``` which is the folder in which the ```wallpaper-picker.sh``` script will be looking for them.

#### 5. Get the hardware configuration

It will also automatically copy the hardware configuration from ```/etc/nixos/hardware-configuration.nix``` to ```./hosts/${host}/hardware-configuration.nix``` so that the hardware configuration used is yours and not the default one.

#### 6. Choose a host (desktop / laptop)

Now you will need to choose the host you want. It depend on whether you are using a desktop or laptop (or a VM altho it can be really buggy).

#### 7. Choose whether to install Aseprite

To reduce installation time, you can choose to skip installing Aseprite. The installation process for Aseprite is time-intensive as it requires compiling over 1100 C++ files from source.

#### 8. Build the system

Lastly, it will build the system, which includes both the flake config and home-manager config.

### VSCode Remote-WSL Integration

This configuration includes helper tools for managing VSCode extensions declaratively in WSL.

**Install all declarative extensions:**
```bash
vscode-install-extensions
```

**Copy extensions recommendations to your project:**
```bash
cp ~/.vscode-remote/extensions.json ~/your-project/.vscode/
```

**Extension Management:**
- Extensions are defined in `modules/home/vscode-extensions.nix`
- Shared between desktop VSCode and WSL Remote-WSL
- `.vscode-remote/extensions.json` contains recommendations list
- `.vscode-remote/wsl-settings.json` contains WSL-specific settings

This allows you to use Windows VSCode with Remote-WSL extension while maintaining declarative extension management through NixOS.

<br/>

## 📝 Shell Aliases

<details>
<summary>
Utils (EXPAND)
</summary>

- ```c```     $\rightarrow$ ```clear```
- ```cd```    $\rightarrow$ ```z```
- ```tt```    $\rightarrow$ ```gtrash put```
- ```vim```   $\rightarrow$ ```nvim```
- ```cat```   $\rightarrow$ ```bat```
- ```nano```  $\rightarrow$ ```micro```
- ```code```  $\rightarrow$ ```codium```
- ```diff```  $\rightarrow$ ```delta --diff-so-fancy --side-by-side```
- ```less```  $\rightarrow$ ```bat```
- ```y```     $\rightarrow$ ```yazi```
- ```py```    $\rightarrow$ ```python```
- ```ipy```   $\rightarrow$ ```ipython```
- ```icat```  $\rightarrow$ ```kitten icat```
- ```dsize``` $\rightarrow$ ```du -hs```
- ```pdf```   $\rightarrow$ ```tdf```
- ```open```  $\rightarrow$ ```xdg-open```
- ```space``` $\rightarrow$ ```ncdu```
- ```man```   $\rightarrow$ ```BAT_THEME='default' batman```
- ```l```     $\rightarrow$ ```eza --icons  -a --group-directories-first -1```
- ```ll```    $\rightarrow$ ```eza --icons  -a --group-directories-first -1 --no-user --long```
- ```tree```  $\rightarrow$ ```eza --icons --tree --group-directories-first```
</details>

<details>
<summary>
NixOS (EXPAND)
</summary>

- ```cdnix```      $\rightarrow$ ```cd ~/moshpitcodes.nix && codium ~/moshpitcodes.nix```
- ```ns```         $\rightarrow$ ```nom-shell --run zsh```
- ```nix-test```   $\rightarrow$ ```nh os test```
- ```nix-switch``` $\rightarrow$ ```nh os switch```
- ```nix-update``` $\rightarrow$ ```nh os switch --update```
- ```nix-clean```  $\rightarrow$ ```nh clean all --keep 5```
- ```nix-search``` $\rightarrow$ ```nh search```
</details>

<details>
<summary>
Git (EXPAND)
</summary>

- ```g```     $\rightarrow$ ```lazygit```
- ```gf```    $\rightarrow$ ```onefetch --number-of-file-churns 0 --no-color-palette```
- ```ga```    $\rightarrow$ ```git add```
- ```gaa```   $\rightarrow$ ```git add --all```
- ```gs```    $\rightarrow$ ```git status```
- ```gb```    $\rightarrow$ ```git branch```
- ```gm```    $\rightarrow$ ```git merge```
- ```gd```    $\rightarrow$ ```git diff```
- ```gpl```   $\rightarrow$ ```git pull```
- ```gplo```  $\rightarrow$ ```git pull origin```
- ```gps```   $\rightarrow$ ```git push```
- ```gpso```  $\rightarrow$ ```git push origin```
- ```gpst```  $\rightarrow$ ```git push --follow-tags```
- ```gcl```   $\rightarrow$ ```git clone```
- ```gc```    $\rightarrow$ ```git commit```
- ```gcm```   $\rightarrow$ ```git commit -m```
- ```gcma```  $\rightarrow$ ```git add --all && git commit -m```
- ```gtag```  $\rightarrow$ ```git tag -ma```
- ```gch```   $\rightarrow$ ```git checkout```
- ```gchb```  $\rightarrow$ ```git checkout -b```
- ```glog```  $\rightarrow$ ```git log --oneline --decorate --graph```
- ```glol```  $\rightarrow$ ```git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset'```
- ```glola``` $\rightarrow$ ```git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' --all```
- ```glols``` $\rightarrow$ ```git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' --stat```

</details>

<br/>

## 🛠️ Scripts

All the scripts located in ```modules/home/scripts/scripts/``` are exported as packages in ```modules/home/scripts/default.nix```

<details>
<summary>
extract.sh
</summary>

**Description:** Script for extracting ```tar.gz``` archives in the current directory.

**Usage:** ```extract <archive_file>```
</details>

<details>
<summary>
compress.sh
</summary>

**Description:** Script for compressing a file or a folder into a ```tar.gz``` archive in the current directory with the name of the chosen file or folder.

**Usage:** ```compress <file>``` or ```compress <folder>```
</details>

<details>
<summary>
toggle_blur.sh
</summary>

**Description:** Script for toggling the Hyprland blur effect. If the blur is currently enabled, it will be disabled and vice versa.

**Usage:** ```toggle_blur```
</details>

<details>
<summary>
toggle_opacity.sh
</summary>

**Description:** Script for toggling the Hyperland opacity effect. If the opacity is currently set to 0.90, it will be set to 1 and vice versa.

**Usage:** ```toggle_opacity```
</details>

<details>
<summary>
maxfetch.sh
</summary>

**Description:** Modified version of the [jobcmax/maxfetch][maxfetch] script.

**Usage:** ```maxfetch```
</details>

<details>
<summary>
music.sh
</summary>

**Description:** Script for managing Audacious (music player). If Audacious is currently running, it will be killed (stopping the music); otherwise, it will start Audacious in the 8th workspace and resume the music.

**Usage:** ```music```
</details>

<details>
<summary>
runbg.sh
</summary>

**Description:** Script for running a provided command along with its arguments and detaching it from the terminal. Handy for launching apps from the command line without blocking it.

**Usage:** ```runbg <command> <arg1> <arg2> <...>```
</details>

<br/>

## 🧪 Development Shells

This repository includes specialized development environments using Nix shells. These provide isolated, reproducible environments for specific workflows.

### Claude Flow

Enterprise AI agent orchestration platform development environment.

**Features:**
- Node.js 24 with npm
- Python 3 + C/C++ build toolchain
- AgentDB vector storage (persists in `.swarm/memory.db`)
- 100+ MCP integrated tools
- 25+ specialized skills
- Multi-agent workflows (2.8-4.4x faster than single-agent)

**Usage:**
```bash
nix develop .#claude-flow
npx claude-flow@alpha init --force
npx claude-flow@alpha --help
```

**Aliases available in shell:**
- `cf` - Run claude-flow commands
- `cf-help` - Show help
- `cf-init` - Initialize claude-flow

**Data Persistence:**
AgentDB stores vector embeddings in `.swarm/memory.db` within your project directory. This data persists across shell sessions and system reboots.

See [shells/README.md](shells/README.md) for more details.

<br/>

## ⌨️ Keybinds

You can view all keybinds by pressing ```$mainMod F1``` and the wallpaper picker by pressing ```$mainMod w```. By default, ```$mainMod``` is the ```SUPER``` key.

<br/>

## 🖼️ Gallery

<p align="center">
   <img src="./.github/assets/screenshots/system-usage.png" style="margin-bottom: 15px;"/> <br>
   Screenshots last updated <b>2025-03-25</b>
</p>

<br/>

# 👥 Credits

Other dotfiles that have inspired me greatly:

- NixOS & Flakes
  - [alt-f4-llc/kickstart.nix](https://github.com/ALT-F4-LLC/kickstart.nix): Forever grateful for BG and the crew!
  - [alt-f4-llc/dotfiles.nix](https://github.com/ALT-F4-LLC/dotfiles.nix): Well, what can I say \o/
  - [mitchellh/nixos-config](https://github.com/mitchellh/nixos-config): The man himself!
  - [frost-phoenix/nixos-config](https://github.com/Frost-Phoenix/nixos-config/tree/catppuccin): General flake / files structure
  - [fufexan/dotfiles](https://github.com/fufexan/dotfiles)
  - [tluijken/.dotfiles](https://github.com/tluijken/.dotfiles): Base rofi config
  - [mrh/dotfiles](https://codeberg.org/mrh/dotfiles): Base Waybar config

- README
  - [ryan4yin/nix-config](https://github.com/ryan4yin/nix-config)
  - [notashelf/nyx](https://github.com/NotAShelf/nyx)
  - [sioodmy/dotfiles](https://github.com/sioodmy/dotfiles)
  - [ruixi-rebirth/flakes](https://github.com/Ruixi-rebirth/flakes)
  - [My Nix Journey](https://tech.aufomm.com/my-nix-journey-use-nix-with-ubuntu/)

- Official Resources
  - [NixOS Homepage](https://nixos.org/)
  - [NixOS Manual](https://nixos.org/manual/nixos/stable/)
  - [NixOS Flakes](https://wiki.nixos.org/wiki/Flakes)
  - [NixOS Download](https://nixos.org/download/#nixos-iso)
  - [nixpkgs](https://github.com/NixOS/nixpkgs)
  - [Home Manager Manual](https://nix-community.github.io/home-manager/)

<br/>

<!-- # ✨ Stars History -->

<br/>

<p align="center"><img src="https://api.star-history.com/svg?repos=MoshPitCodes/moshpitcodes.nix&type=Timeline&theme=dark" /></p>

<br/>

<p align="center"><img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/footers/gray0_ctp_on_line.svg?sanitize=true" /></p>

<!-- end of page, send back to the top -->

<div align="right">
  <a href="#readme">Back to the Top</a>
</div>

<!-- Links -->
[Wayland]: https://wayland.freedesktop.org/
[Hyprland]: https://github.com/hyprwm/Hyprland
[Waypaper]:https://github.com/anufrievroman/waypaper
[Hyprpaper]: hhttps://github.com/hyprwm/hyprpaper
[Ghostty]: https://ghostty.org/
[powerlevel10k]: https://github.com/romkatv/powerlevel10k
[Waybar]: https://github.com/Alexays/Waybar
[rofi]: https://github.com/lbonn/rofi
[Btop]: https://github.com/aristocratos/btop
[nemo]: https://github.com/linuxmint/nemo/
[yazi]: https://github.com/sxyazi/yazi
[zsh]: https://ohmyz.sh/
[Swaylock-effects]: https://github.com/mortie/swaylock-effects
[Hyprlock]: https://github.com/hyprwm/hyprlock
[audacious]: https://audacious-media-player.org/
[mpv]: https://github.com/mpv-player/mpv
[VSCodium]:https://vscodium.com/
[VSCode]: https://code.visualstudio.com/
[Neovim]: https://github.com/neovim/neovim
[CursorAI]: https://www.cursor.com/
[grimblast]: https://github.com/hyprwm/contrib
[Gruvbox]: https://github.com/morhetz/gruvbox
[Hyprland]: https://github.com/hyprwm/Hyprland
[Hyprlock]: https://github.com/hyprwm/hyprlock
[Hyprpaper]: https://github.com/hyprwm/hyprpaper
[hyprpicker]: https://github.com/hyprwm/hyprpicker
[imv]: https://sr.ht/~exec64/imv/
[swaync]: https://github.com/ErikReider/SwayNotificationCenter
[Maple Mono]: https://github.com/subframe7536/maple-font
[NetworkManager]: https://wiki.gnome.org/Projects/NetworkManager
[network-manager-applet]: https://gitlab.gnome.org/GNOME/network-manager-applet/
[wl-clip-persist]: https://github.com/Linus789/wl-clip-persist
[wf-recorder]: https://github.com/ammen99/wf-recorder
[hyprpicker]: https://github.com/hyprwm/hyprpicker
[Gruvbox]: https://github.com/morhetz/gruvbox
[Papirus-Dark]: https://github.com/PapirusDevelopmentTeam/papirus-icon-theme
[Bibata-Modern-Ice]: https://www.gnome-look.org/p/1197198
[maxfetch]: https://github.com/jobcmax/maxfetch
[Colloid GTK Theme]: https://github.com/vinceliuice/Colloid-gtk-theme
[OBS]: https://obsproject.com/
