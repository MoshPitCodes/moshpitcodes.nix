# External Secrets Management Guide

## Overview

This system uses **external secret files** stored on the NAS to keep sensitive data out of the Nix configuration and Git repository.

## Supported Secret Types

| Secret Type | Storage Method | Auto-Loaded |
|-------------|----------------|-------------|
| SSH Keys | File copy from NAS | ✅ Yes (on activation) |
| GPG Keys | File copy from NAS | ✅ Yes (on activation) |
| GitHub CLI Tokens | File copy from NAS | ✅ Yes (on activation) |
| Samba Password | Credentials file | ✅ Yes (system activation) |
| API Keys & Tokens | Environment variables | ✅ Yes (shell sessions) |

## Storage Location

All secrets are stored on the NAS at:
```
/mnt/ugreen-nas/Coding/SecretsBackup2025/.secrets/
```

## Setup Instructions

### 1. Store API Keys and Tokens

Edit the external secrets file on the NAS:
```bash
nano /mnt/ugreen-nas/Coding/SecretsBackup2025/.secrets/env-secrets.sh
```

Add your secrets:
```bash
#!/usr/bin/env bash
# External Secrets File

# API Keys
export ANTHROPIC_API_KEY="sk-ant-..."
export OPENAI_API_KEY="sk-..."

# Cloud Providers
export AWS_ACCESS_KEY_ID="AKIA..."
export AWS_SECRET_ACCESS_KEY="..."

# GitHub
export GITHUB_TOKEN="ghp_..."

# Custom secrets
export MY_SECRET="value"
```

Save and set proper permissions:
```bash
chmod 600 /mnt/ugreen-nas/Coding/SecretsBackup2025/.secrets/env-secrets.sh
```

### 2. Rebuild System

```bash
sudo nixos-rebuild switch --flake .#wsl --impure
```

The secrets file will be copied to `~/.secrets/env-secrets.sh` and automatically sourced in new shell sessions.

### 3. Verify Secrets Loaded

```bash
# Open new terminal and check
echo $ANTHROPIC_API_KEY
echo $GITHUB_TOKEN
```

## How It Works

### Automatic Loading

The `modules/home/secrets-loader.nix` module:

1. **During activation**: Copies `env-secrets.sh` from NAS to `~/.secrets/`
2. **In shell sessions**: Sources `~/.secrets/env-secrets.sh` automatically
3. **Environment variables**: Available to all programs in your shell

### Backup Integration

The automated backup system (`modules/home/key-backup.nix`) backs up:
- SSH keys
- GPG keyring
- GitHub CLI config
- **Secret files** (env-secrets.sh)

Runs weekly on Monday at 00:00.

## Security Best Practices

### ✅ DO

- Store secrets in external files on the NAS
- Use restrictive permissions (600 for secret files)
- Keep secrets.nix empty/minimal
- Use environment variables in applications
- Review secrets regularly

### ❌ DON'T

- Commit secrets to Git
- Store secrets in `secrets.nix` (except hashed passwords)
- Share secret files via email/chat
- Use overly permissive file permissions
- Store secrets in the Nix store

## File Structure

```
NAS Storage:
/mnt/ugreen-nas/Coding/SecretsBackup2025/
├── .ssh/                     # SSH keys
│   ├── id_ed25519_github
│   ├── id_ed25519_proxmox
│   └── ...
├── .gnupg/                   # GPG keyring
├── .config/gh/               # GitHub CLI auth
└── .secrets/                 # New: External secrets
    ├── samba-credentials     # Samba password
    └── env-secrets.sh        # API keys and tokens

Local System (after activation):
~/.secrets/
└── env-secrets.sh            # Copied from NAS, sourced in shell
```

## Accessing Secrets in Programs

### Shell Scripts
```bash
#!/usr/bin/env bash
# Secrets are already loaded as environment variables
curl -H "Authorization: Bearer $GITHUB_TOKEN" https://api.github.com/user
```

### Python
```python
import os

api_key = os.environ.get('ANTHROPIC_API_KEY')
github_token = os.environ.get('GITHUB_TOKEN')
```

### Node.js
```javascript
const anthropicKey = process.env.ANTHROPIC_API_KEY;
const githubToken = process.env.GITHUB_TOKEN;
```

### Go
```go
import "os"

apiKey := os.Getenv("ANTHROPIC_API_KEY")
githubToken := os.Getenv("GITHUB_TOKEN")
```

## Troubleshooting

### Secrets Not Loading

```bash
# Check if secrets file exists locally
ls -la ~/.secrets/

# Check if NAS is mounted
mount | grep ugreen

# Manually copy from NAS
cp /mnt/ugreen-nas/Coding/SecretsBackup2025/.secrets/env-secrets.sh ~/.secrets/
chmod 600 ~/.secrets/env-secrets.sh

# Source in current shell
source ~/.secrets/env-secrets.sh

# Rebuild to trigger activation
sudo nixos-rebuild switch --flake .#wsl --impure
```

### Environment Variable Not Set

```bash
# Check if file is sourced
cat ~/.zshrc | grep env-secrets

# Manually source
source ~/.secrets/env-secrets.sh

# Check variable
echo $ANTHROPIC_API_KEY

# Verify file contains variable
cat ~/.secrets/env-secrets.sh | grep ANTHROPIC_API_KEY
```

### Permission Denied

```bash
# Fix permissions on local copy
chmod 600 ~/.secrets/env-secrets.sh

# Fix permissions on NAS
chmod 600 /mnt/ugreen-nas/Coding/SecretsBackup2025/.secrets/env-secrets.sh
```

## Migration Guide

### Moving Secrets from secrets.nix to External File

1. **Identify secrets** in `secrets.nix`:
   ```nix
   apiKeys = {
     anthropic = "sk-ant-...";  # Move this
     openai = "sk-...";          # Move this
   };
   ```

2. **Add to external file**:
   ```bash
   nano /mnt/ugreen-nas/Coding/SecretsBackup2025/.secrets/env-secrets.sh
   ```
   
   Add:
   ```bash
   export ANTHROPIC_API_KEY="sk-ant-..."
   export OPENAI_API_KEY="sk-..."
   ```

3. **Update secrets.nix**:
   ```nix
   apiKeys = {
     anthropic = "";  # Now uses env var
     openai = "";     # Now uses env var
   };
   ```

4. **Rebuild and test**:
   ```bash
   sudo nixos-rebuild switch --flake .#wsl --impure
   # Open new terminal
   echo $ANTHROPIC_API_KEY
   ```

## Advanced: Per-Environment Secrets

You can have different secret files for different environments:

```bash
# Development
~/.secrets/env-secrets-dev.sh

# Production
~/.secrets/env-secrets-prod.sh

# In .zshrc:
if [[ "$ENVIRONMENT" == "prod" ]]; then
  source ~/.secrets/env-secrets-prod.sh
else
  source ~/.secrets/env-secrets-dev.sh
fi
```

## Comparison with Other Solutions

| Method | Pros | Cons |
|--------|------|------|
| **External Files (Current)** | Simple, no extra tools, works everywhere | Manual file management |
| **agenix** | Encrypted secrets, Git-friendly | More complex, requires key management |
| **sops-nix** | Industry standard, good tooling | Learning curve, extra dependencies |
| **1Password** | GUI, biometrics, sync | Proprietary, requires subscription |
| **HashiCorp Vault** | Enterprise-grade, dynamic secrets | Overkill for personal use, complex |

For a single-user homelab, **external files are the sweet spot** between security and simplicity.

## Related Documentation

- Main key management guide: `docs/ssh-gpg-key-management.md`
- Security improvements: `docs/CHANGES-KEY-MANAGEMENT.md`
- 1Password GPG integration: `docs/SETUP-1PASSWORD-GPG.md`

## Quick Reference

```bash
# View secrets file
cat ~/.secrets/env-secrets.sh

# Edit secrets (on NAS)
nano /mnt/ugreen-nas/Coding/SecretsBackup2025/.secrets/env-secrets.sh

# Reload secrets in current shell
source ~/.secrets/env-secrets.sh

# Trigger backup
backup-keys

# Check backup timer
systemctl --user list-timers | grep backup

# List all environment variables
env | grep -E 'API_KEY|TOKEN|SECRET'
```
