# Configuration Guide

This guide covers customizing your NixOS configuration before and after installation.

## Monitor Configuration

**File:** `./modules/home/hyprland/config.nix`

Run `hyprctl monitors all` to check for the identifiers/names of your monitors, then update the configuration accordingly.

## Wallpaper Configuration

**Files:**
- `./modules/home/waypaper.nix`
- `./modules/home/hyprland/hyprpaper.nix`
- `./modules/home/hyprland/hyprlock.nix`

Wallpapers are stored in `~/Pictures/wallpapers/` and managed by waypaper/hyprpaper.

## Wi-Fi Configuration

> [!TIP]
> Wi-Fi configuration is handled via `secrets.nix`. Set `network.wifiSSID` and `network.wifiPassword` in your secrets file.

The network module at `./modules/core/network.nix` reads credentials from `secrets.nix` automatically.

## Git Configuration

> [!TIP]
> Git configuration is handled automatically via `secrets.nix`.

Configure in the `git` section of your secrets file:
- `git.userName` - Your git display name
- `git.userEmail` - Your git email
- `git.user.signingkey` - Your GPG key ID (optional)

The git configuration in `./modules/home/git.nix` reads from `secrets.nix`.

## VSCode Extensions

**File:** `./modules/home/vscode.nix`

```nix
{
   profiles.default = {
      extensions = with pkgs.vscode-extensions; [
         # nix language
         jnoortheen.nix-ide

         # add more VSCode extensions
      ];
   };
}
```

## Aseprite Theme

**Files:** `./modules/home/aseprite/themes`

## Audacious

> [!TIP]
> Audacious music path is automatically configured using your username from `secrets.nix`. No manual configuration needed.

## Rebuild Script

For subsequent rebuilds after initial installation, use the rebuild script:

**Usage:**
```bash
./scripts/rebuild.sh [HOST] [OPTIONS]
```

**Arguments:**
- `HOST` - Host configuration (default: laptop)
  - Available hosts: desktop, laptop, vm, vmware-guest, wsl

**Options:**
- `--clear-cache` - Clear `~/.cache/nix` before rebuild
- `--gc, --garbage-collect` - Run garbage collection before rebuild
- `-n, --dry-run` - Show what would be built without building
- `-h, --help` - Show help message and list available hosts

**Examples:**
```bash
# Rebuild laptop configuration
./scripts/rebuild.sh laptop

# Rebuild with garbage collection
./scripts/rebuild.sh desktop --gc

# Dry run to see what would change
./scripts/rebuild.sh wsl --dry-run

# Clear cache and rebuild
./scripts/rebuild.sh laptop --clear-cache
```

## Shell Aliases

### Utils
| Alias | Command |
|-------|---------|
| `c` | `clear` |
| `cd` | `z` |
| `tt` | `gtrash put` |
| `vim` | `nvim` |
| `cat` | `bat` |
| `nano` | `micro` |
| `code` | `codium` |
| `y` | `yazi` |
| `l` | `eza --icons -a --group-directories-first -1` |
| `ll` | `eza --icons -a --group-directories-first -1 --no-user --long` |
| `tree` | `eza --icons --tree --group-directories-first` |

### NixOS
| Alias | Command |
|-------|---------|
| `cdnix` | `cd ~/moshpitcodes.nix && codium ~/moshpitcodes.nix` |
| `ns` | `nom-shell --run zsh` |
| `nd` | `nom develop --command zsh` |
| `nb` | `nom build` |
| `nix-switch` | `sudo nixos-rebuild switch --flake .` |
| `nix-test` | `sudo nixos-rebuild test --flake .` |
| `nix-update` | `nix flake update` |
| `nix-clean` | `sudo nix-collect-garbage -d` |
| `nix-search` | `nix search nixpkgs` |

### Git
| Alias | Command |
|-------|---------|
| `g` | `lazygit` |
| `ga` | `git add` |
| `gaa` | `git add --all` |
| `gs` | `git status` |
| `gb` | `git branch` |
| `gd` | `git diff` |
| `gpl` | `git pull` |
| `gps` | `git push` |
| `gc` | `git commit` |
| `gcm` | `git commit -m` |
| `gcma` | `git add --all && git commit -m` |
| `gch` | `git checkout` |
| `gchb` | `git checkout -b` |
| `glog` | `git log --oneline --decorate --graph` |

## Keybinds

View all keybinds by pressing `$mainMod F1` and the wallpaper picker by pressing `$mainMod w`. By default, `$mainMod` is the `SUPER` key.
