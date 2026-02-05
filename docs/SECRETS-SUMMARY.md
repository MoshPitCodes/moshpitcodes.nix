# Secrets Management Summary

## What Was Implemented

Extended the external secrets approach to support **all types of secrets**, not just SSH/GPG keys.

## Before vs After

### Before ❌
```nix
# secrets.nix (committed to Git, even though git-ignored)
apiKeys = {
  anthropic = "sk-ant-api-key-here";  # Plaintext in config
  openai = "sk-openai-key-here";      # Plaintext in config
};

samba = {
  password = "plaintext-password";    # Plaintext in config
};
```

### After ✅
```bash
# External file on NAS (never in Git)
/mnt/ugreen-nas/.../secrets/env-secrets.sh
export ANTHROPIC_API_KEY="sk-ant-..."
export OPENAI_API_KEY="sk-..."
export GITHUB_TOKEN="ghp_..."
```

```nix
# secrets.nix (clean, no sensitive data)
apiKeys = {
  anthropic = "";  # Uses ANTHROPIC_API_KEY env var
  openai = "";     # Uses OPENAI_API_KEY env var
};

samba = {
  credentialsFile = "/path/to/nas/.secrets/samba-credentials";
};
```

## Secret Storage Locations

| Secret Type | Storage Path | Loaded When | Available To |
|-------------|--------------|-------------|--------------|
| SSH Keys | `~/.ssh/` | System activation | SSH client |
| GPG Keys | `~/.gnupg/` | System activation | GPG agent |
| GitHub CLI | `~/.config/gh/` | System activation | gh CLI |
| Samba Password | `/root/.secrets/samba-credentials` | System activation | Mount service |
| API Keys & Tokens | `~/.secrets/env-secrets.sh` | Shell startup | All programs |

## How to Use

### 1. Add New Secrets

Edit the file on the NAS:
```bash
nano /mnt/ugreen-nas/Coding/SecretsBackup2025/.secrets/env-secrets.sh
```

Add your secret:
```bash
export MY_NEW_API_KEY="secret-value"
```

### 2. Rebuild System

```bash
sudo nixos-rebuild switch --flake .#wsl --impure
```

The file is copied to `~/.secrets/env-secrets.sh` automatically.

### 3. Use in New Shell Sessions

```bash
# Open new terminal
echo $MY_NEW_API_KEY
# Output: secret-value
```

### 4. Use in Current Shell (Optional)

```bash
# Load without rebuilding
source ~/.secrets/env-secrets.sh
echo $MY_NEW_API_KEY
```

## Files Added

1. **`modules/home/secrets-loader.nix`**
   - Copies `env-secrets.sh` from NAS to `~/.secrets/`
   - Configures zsh/bash to source the file automatically

2. **`/mnt/ugreen-nas/.../secrets/env-secrets.sh`**
   - Template with common secret types
   - Automatically sourced in shell sessions

3. **`docs/EXTERNAL-SECRETS-GUIDE.md`**
   - Comprehensive guide with examples
   - Troubleshooting and migration instructions

## Files Modified

1. **`secrets.nix`**
   - Added comments recommending external file approach
   - Documented where to store API keys

2. **`modules/home/key-backup.nix`**
   - Now also backs up `~/.secrets/env-secrets.sh` to NAS

3. **`modules/home/default.wsl.nix`**
   - Added `./secrets-loader.nix` import

## Benefits

### Security
- ✅ No secrets committed to Git (even accidentally)
- ✅ Secrets not in Nix store (world-readable)
- ✅ Proper file permissions (600)
- ✅ Centralized secret management

### Convenience
- ✅ Automatic loading in shell sessions
- ✅ Works with all programming languages (env vars)
- ✅ Automatic backup to NAS (weekly)
- ✅ Easy to add/update secrets

### Flexibility
- ✅ Supports any secret type
- ✅ No external dependencies
- ✅ Works offline (after initial copy)
- ✅ Compatible with all tools

## Supported Secret Types

The `env-secrets.sh` template includes:

- **API Keys**: Anthropic, OpenAI, etc.
- **Cloud Providers**: AWS, Azure, GCP credentials
- **Database**: Connection strings, passwords
- **Service Tokens**: GitHub, GitLab, Docker Hub
- **Custom Secrets**: Any environment variable

## Migration Checklist

If you have secrets in `secrets.nix`, migrate them:

- [ ] Create `env-secrets.sh` on NAS with your secrets
- [ ] Rebuild system to copy file locally
- [ ] Test secrets are loaded: `echo $VARIABLE_NAME`
- [ ] Remove plaintext secrets from `secrets.nix`
- [ ] Commit the cleaned `secrets.nix`
- [ ] Verify applications still work

## Quick Commands

```bash
# Edit secrets
nano /mnt/ugreen-nas/Coding/SecretsBackup2025/.secrets/env-secrets.sh

# Reload in current shell
source ~/.secrets/env-secrets.sh

# View all secrets (careful!)
cat ~/.secrets/env-secrets.sh

# Check if secret is set
echo $ANTHROPIC_API_KEY

# List all environment variables with secrets
env | grep -E 'API_KEY|TOKEN|SECRET|PASSWORD'

# Backup secrets manually
backup-keys

# Check backup status
backup-keys-status
```

## Architecture

```
┌─────────────────────────────────────────────────┐
│         NAS (Source of Truth)                   │
│  /mnt/ugreen-nas/.../secrets/                   │
│  ├── samba-credentials                          │
│  └── env-secrets.sh                             │
└──────────────────┬──────────────────────────────┘
                   │
                   │ Copy on activation
                   ▼
┌─────────────────────────────────────────────────┐
│         Local System                            │
│  ~/.secrets/                                    │
│  └── env-secrets.sh (sourced in shell)         │
└─────────────────────────────────────────────────┘
                   │
                   │ Loaded as env vars
                   ▼
┌─────────────────────────────────────────────────┐
│         Applications                            │
│  - Python: os.environ['API_KEY']               │
│  - Node: process.env.API_KEY                   │
│  - Go: os.Getenv("API_KEY")                    │
│  - Bash: $API_KEY                              │
└─────────────────────────────────────────────────┘
```

## Backup Flow

```
Weekly Timer (Monday 00:00)
  ↓
systemd service: backup-keys.service
  ↓
Rsync to NAS:
  - SSH keys → .ssh/
  - GPG keys → .gnupg/
  - GitHub CLI → .config/gh/
  - Secrets → .secrets/env-secrets.sh
  ↓
Set permissions (600/644)
  ↓
Done ✅
```

## Next Steps

1. **Fill in your secrets** in `env-secrets.sh`
2. **Remove plaintext secrets** from `secrets.nix`
3. **Test applications** still work with env vars
4. **Review regularly** and rotate keys as needed

## Documentation

- **Quick Start**: `docs/EXTERNAL-SECRETS-GUIDE.md`
- **Key Management**: `docs/ssh-gpg-key-management.md`
- **Changes Log**: `docs/CHANGES-KEY-MANAGEMENT.md`
- **1Password Setup**: `docs/SETUP-1PASSWORD-GPG.md`

## Support

If secrets aren't loading:
1. Check file exists: `ls -la ~/.secrets/`
2. Check permissions: Should be `600`
3. Check zshrc: `cat ~/.zshrc | grep env-secrets`
4. Reload shell or rebuild system
5. Check NAS is mounted: `mount | grep ugreen`

---

**Status**: ✅ Fully Implemented and Tested
**Last Updated**: 2026-02-05
