# Secrets Management Migration Guide

This document explains the migration from the old `secrets.nix` approach to the new external secrets system using `config.nix`.

## Overview

### Old Approach (Deprecated)
- **`secrets.nix`** (git-ignored): Contains all secrets including passwords, API keys
- Required `--impure` flag for evaluation
- Secrets embedded in Nix store during build

### New Approach (Recommended)
- **`config.nix`** (safe to commit): Contains paths to external secret files
- **External files on NAS**: Actual secret values stored separately
- Pure evaluation (no `--impure` needed for most operations)
- Secrets loaded at runtime, never in Nix store

## Architecture

```
config.nix (Git)          External Secrets (NAS)
------------------        ----------------------
username = "..."   --->   /mnt/nas/.secrets/
git.userName = "..."      ├── user-password-hash
git.userEmail = "..."     ├── samba-credentials
external = {              ├── env-secrets.sh
  secretsDir = "..."      └── ...
  userPasswordFile = "..."
  sambaCredentials = "..."
  envSecrets = "..."
}
```

## Secret Types and Storage

| Secret Type | Storage Location | Loaded When |
|-------------|------------------|-------------|
| User password hash | `user-password-hash` | Boot (by systemd) |
| Samba credentials | `samba-credentials` | Activation script |
| API keys | `env-secrets.sh` | Shell startup |
| SSH keys | `.ssh/` directory | Home-manager activation |
| GPG keyring | `.gnupg/` directory | Home-manager activation |
| GitHub CLI config | `.config/gh/` | Home-manager activation |

## Migration Steps

### 1. Set Up External Secrets Directory

Run the setup script:

```bash
./scripts/setup-secrets.sh /mnt/ugreen-nas/Coding/SecretsBackup2025/.secrets
```

This creates:
- `user-password-hash` - User's hashed password
- `samba-credentials` - Samba/CIFS credentials
- `env-secrets.sh` - Environment variables (API keys)

### 2. Create Secret Files Manually (Alternative)

If you prefer manual setup:

```bash
# Create directories
mkdir -p /mnt/nas/.secrets
chmod 700 /mnt/nas/.secrets

# User password (generate hash)
mkpasswd -m sha-512 > /mnt/nas/.secrets/user-password-hash
chmod 600 /mnt/nas/.secrets/user-password-hash

# Samba credentials
cat > /mnt/nas/.secrets/samba-credentials << EOF
username=your_username
password=your_password
domain=WORKGROUP
EOF
chmod 600 /mnt/nas/.secrets/samba-credentials

# Environment secrets
cat > /mnt/nas/.secrets/env-secrets.sh << 'EOF'
#!/usr/bin/env bash
export ANTHROPIC_API_KEY="sk-ant-..."
export OPENAI_API_KEY="sk-..."
export GITHUB_TOKEN="ghp_..."
EOF
chmod 600 /mnt/nas/.secrets/env-secrets.sh
```

### 3. Update config.nix

Ensure your `config.nix` has the correct paths:

```nix
{
  username = "yourusername";
  
  git = {
    userName = "Your Name";
    userEmail = "your@email.com";
    signingkey = "YOUR_GPG_KEY_ID";
  };
  
  external = {
    secretsDir = "/mnt/nas/.secrets";
    userPasswordFile = "/mnt/nas/.secrets/user-password-hash";
    sambaCredentials = "/mnt/nas/.secrets/samba-credentials";
    envSecrets = "/mnt/nas/.secrets/env-secrets.sh";
    sshKeysDir = "/mnt/nas/.ssh";
    sshKeys = [ "id_ed25519_github" ];
    gpgDir = "/mnt/nas/.gnupg";
    ghConfigDir = "/mnt/nas/.config/gh";
  };
}
```

### 4. Remove secrets.nix (Optional)

Once migration is complete, you can delete `secrets.nix`:

```bash
rm secrets.nix
```

The flake will fall back to `config.nix` automatically.

## How Secrets Are Loaded

### User Password
The user password hash is loaded via NixOS's `hashedPasswordFile` option:
```nix
users.users.${username}.hashedPasswordFile = "/mnt/nas/.secrets/user-password-hash";
```
This is read by systemd at boot time, not during Nix evaluation.

### Samba Credentials
Copied to `/root/.secrets/samba-credentials` during system activation:
```bash
# Activation script copies from NAS to local cache
cp /mnt/nas/.secrets/samba-credentials /root/.secrets/samba-credentials
```

### API Keys
Loaded at shell startup via `.zshrc`/`.bashrc`:
```bash
source ~/.secrets/env-secrets.sh
```
The file is copied from NAS during home-manager activation.

### SSH/GPG Keys
Copied during home-manager activation:
```bash
# SSH keys
cp -r /mnt/nas/.ssh/* ~/.ssh/

# GPG keyring
cp -r /mnt/nas/.gnupg/* ~/.gnupg/
```

## Offline Operation

The system caches secrets locally for offline operation:
- `/root/.secrets/` - System-level secrets (samba)
- `~/.secrets/` - User-level secrets (API keys)
- `~/.ssh/`, `~/.gnupg/` - Keys

If the NAS is unavailable:
1. Cached secrets are used
2. Warning messages are logged
3. System continues to function

## Security Considerations

### Advantages of External Secrets
1. **Not in Nix store**: Secrets never end up in `/nix/store/`
2. **Not in Git**: Even accidentally, paths not values
3. **Centralized management**: Single source on NAS
4. **Proper permissions**: Files can have restrictive permissions

### Best Practices
1. **NAS security**: Ensure NAS has proper access controls
2. **Permissions**: All secret files should be `0600` or `0400`
3. **Backup**: The `backup-keys` service backs up secrets weekly
4. **Rotation**: Rotate API keys periodically

## Troubleshooting

### Password not working after rebuild
Check if the password file exists and is readable:
```bash
ls -la /mnt/nas/.secrets/user-password-hash
cat /mnt/nas/.secrets/user-password-hash
```

### API keys not available in shell
Check if the secrets file was copied:
```bash
ls -la ~/.secrets/env-secrets.sh
source ~/.secrets/env-secrets.sh
echo $ANTHROPIC_API_KEY
```

### NAS not mounted
Ensure the NAS mount is configured and accessible:
```bash
mount | grep ugreen-nas
ls /mnt/ugreen-nas/
```

## Module Reference

### `mpc.secrets` Options

| Option | Type | Description |
|--------|------|-------------|
| `enable` | bool | Enable MPC secrets management |
| `basePath` | string | Base path for secrets on NAS |
| `userPasswordFile` | string | Relative path to password hash |
| `sambaCredentialsFile` | string | Relative path to samba creds |
| `envSecretsFile` | string | Relative path to env secrets |
| `sshKeysDir` | string | Absolute path to SSH keys |
| `gpgDir` | string | Absolute path to GPG keyring |

## Backwards Compatibility

The system maintains backwards compatibility with `secrets.nix`:

1. If `config.nix` exists with `external` settings -> Uses external files
2. If only `secrets.nix` exists -> Uses embedded secrets (old behavior)
3. If neither exists -> Uses CI defaults (testing only)

To migrate gradually:
1. Create `config.nix` with external paths
2. Keep `secrets.nix` as fallback
3. Test thoroughly
4. Remove `secrets.nix` when confident
