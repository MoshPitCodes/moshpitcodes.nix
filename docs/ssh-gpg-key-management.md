# SSH and GPG Key Management

This document explains how SSH and GPG keys are managed in your NixOS configuration.

## Overview

Your configuration uses a **backup-and-restore** approach for SSH and GPG keys:
- Keys are stored on your NAS at `/mnt/ugreen-nas/Coding/SecretsBackup2025/`
- Keys are automatically copied to your system during home-manager activation
- This ensures keys are available after fresh installs or system rebuilds

## Key Locations

### Backup Source (NAS)
```
/mnt/ugreen-nas/Coding/SecretsBackup2025/
├── .ssh/                     # SSH key backups
│   ├── id_ed25519_github
│   ├── id_ed25519_github.pub
│   ├── id_ed25519_proxmox
│   ├── id_ed25519_proxmox.pub
│   ├── id_ed25519_proxmox_terraform
│   └── id_ed25519_proxmox_terraform.pub
├── .gnupg/                   # GPG keyring backup
│   ├── private-keys-v1.d/
│   ├── openpgp-revocs.d/
│   ├── public-keys.d/
│   ├── trustdb.gpg
│   └── common.conf
└── .config/gh/               # GitHub CLI auth tokens
    ├── config.yml
    └── hosts.yml
```

### Local System
```
~/.ssh/                       # SSH keys (copied from NAS)
~/.gnupg/                     # GPG keys (copied from NAS)
~/.config/gh/                 # GitHub CLI config (copied from NAS)
```

## Configuration Files

### secrets.nix
Defines backup source locations and key names:
```nix
sshKeys = {
  sourceDir = "/mnt/ugreen-nas/Coding/SecretsBackup2025/.ssh";
  keys = [
    "id_ed25519_github"
    "id_ed25519_proxmox"
    "id_ed25519_proxmox_terraform"
  ];
};

ghConfigDir = "/mnt/nas/Coding/SecretsBackup2025/.config/gh";
gpgDir = "/mnt/nas/Coding/SecretsBackup2025/.gnupg";
```

### modules/home/openssh.nix
Handles SSH key management:
- **home.activation.copySSHKeys**: Copies keys from NAS during activation
- **programs.ssh.matchBlocks**: Configures SSH to use specific keys for different hosts
- Sets proper permissions (600 for private keys, 644 for public keys)

### modules/home/gpg.nix
Handles GPG key management:
- **home.activation.copyGpgKeys**: Copies GPG keyring from NAS during activation
- **services.gpg-agent**: Configures GPG agent with:
  - `pinentryPackage = pkgs.pinentry-curses` - Terminal-based password prompts
  - `defaultCacheTtl = 28800` - Cache passphrase for 8 hours
  - `maxCacheTtl = 86400` - Maximum cache time of 24 hours

### modules/home/git.nix
Handles Git configuration and GPG signing:
- **home.activation.copyGhConfig**: Copies GitHub CLI authentication
- Enables commit signing with `commit.gpgsign = true`
- Uses GPG key `81322B518F331E00` for signing

## How It Works

### Initial Setup
1. **System rebuild**: `sudo nixos-rebuild switch --flake .#wsl`
2. **NAS mount**: System auto-mounts NAS via systemd
3. **Home-manager activation**: Copies keys from NAS to local directories
4. **Permission setting**: Sets restrictive permissions on private keys

### SSH Key Usage
```bash
# Keys are automatically loaded by ssh-agent (configured in zsh.nix)
ssh-add -l  # List loaded keys

# SSH config automatically uses the right key:
ssh git@github.com          # Uses id_ed25519_github
ssh root@proxmox.local      # Uses id_ed25519_proxmox
```

### GPG Key Usage
```bash
# Sign a Git commit (automatic with commit.gpgsign=true)
git commit -m "message"

# Manually sign something
echo "test" | gpg --clearsign

# First time will prompt for passphrase (via pinentry-curses)
# Passphrase is cached for 8 hours
```

## Current SSH Keys

| Key Name | Purpose | Fingerprint |
|----------|---------|-------------|
| `id_ed25519_github` | GitHub authentication | SHA256:i/Tpb072CcFwZeF+WEhj4rsI2ZI+Nq992iYnVYaeS/Q |
| `id_ed25519_proxmox` | Proxmox server access | SHA256:IVOn0XWSpvqFb7ILUHafwSbW4qMrf+v7/QflMDyIhTg |
| `id_ed25519_proxmox_terraform` | Terraform automation | SHA256:y9xPn8sF0355/Q85UPrjKFQ36K7Gfx7lguC3Li1x6yM |

## Current GPG Keys

| Key ID | Usage | Description |
|--------|-------|-------------|
| `81322B518F331E00` | Signing | Mosh Pit (Github Signing Key 2025-12-03) |

**Fingerprint**: `2827290D9EFD99E4F8B7F05081322B518F331E00`

## Security Considerations

### Strengths
- ✅ Keys are not stored in the Nix store (which is world-readable)
- ✅ Keys are not committed to Git
- ✅ Proper file permissions enforced (600 for private, 644 for public)
- ✅ GPG passphrase caching reduces prompting while maintaining security
- ✅ SSH keys auto-loaded to agent for convenience

### Weaknesses & Recommendations
- ⚠️ **NAS dependency**: If NAS is unavailable, keys won't be copied
  - *Mitigation*: Keys persist locally after first copy
- ⚠️ **Manual backup required**: Must manually update NAS backups when keys change
  - *Recommendation*: Add automation to sync keys back to NAS
- ⚠️ **Plaintext secrets.nix**: API keys and passwords in secrets.nix
  - *Recommendation*: Consider using `agenix` or `sops-nix` for encryption
- ⚠️ **No key rotation policy**: Keys have no expiration
  - *Recommendation*: Set GPG key expiration and rotate SSH keys annually

## Backup Strategy

### Current: Manual Backup to NAS
Keys are manually copied to NAS and referenced in `secrets.nix`

### Recommended: Automated Backup
Consider adding a systemd timer or cron job to automatically backup keys:

```nix
# Future enhancement
systemd.user.services.backup-keys = {
  description = "Backup SSH and GPG keys to NAS";
  script = ''
    rsync -av --delete ~/.ssh/ /mnt/ugreen-nas/Coding/SecretsBackup2025/.ssh/
    rsync -av --delete ~/.gnupg/ /mnt/ugreen-nas/Coding/SecretsBackup2025/.gnupg/
  '';
};

systemd.user.timers.backup-keys = {
  wantedBy = [ "timers.target" ];
  timerConfig = {
    OnCalendar = "weekly";
    Persistent = true;
  };
};
```

## Troubleshooting

### SSH Key Not Working
```bash
# Check if key is loaded
ssh-add -l

# Manually load key
ssh-add ~/.ssh/id_ed25519_github

# Test GitHub connection
ssh -T git@github.com

# Check SSH config
cat ~/.ssh/config
```

### GPG Passphrase Prompting Too Often
```bash
# Check cache settings
cat ~/.gnupg/gpg-agent.conf

# Restart GPG agent
gpgconf --kill gpg-agent

# Test signing
echo "test" | gpg --clearsign
```

### Keys Not Copied from NAS
```bash
# Check if NAS is mounted
mount | grep ugreen

# Check if source directory exists
ls -la /mnt/ugreen-nas/Coding/SecretsBackup2025/.ssh/

# Manually trigger home-manager activation
sudo nixos-rebuild switch --flake .#wsl
```

### GPG Agent Not Using Correct Pinentry
```bash
# Check current pinentry
gpgconf --list-components | grep pinentry

# Check gpg-agent.conf
cat ~/.gnupg/gpg-agent.conf

# Verify pinentry-curses is installed
which pinentry-curses

# Restart agent
gpgconf --kill gpg-agent
```

## Related Files

- `secrets.nix` - Key sources and Git config
- `modules/home/openssh.nix` - SSH key management
- `modules/home/gpg.nix` - GPG key management
- `modules/home/git.nix` - Git configuration and GitHub CLI
- `modules/core/program.nix` - System-level GPG agent configuration
- `modules/home/zsh/zsh.nix` - SSH agent auto-loading

## Future Enhancements

1. **Secret Encryption**: Use `agenix` or `sops-nix` to encrypt secrets.nix
2. **Key Rotation**: Implement automatic key rotation policy
3. **Automated Backup**: Add systemd timer for periodic key backups to NAS
4. **1Password Integration**: Complete 1Password GPG passphrase integration (already documented)
5. **Multi-System Sync**: Consider using syncthing or git-crypt for multi-machine sync
6. **Hardware Security Key**: Add support for YubiKey or similar HSM
