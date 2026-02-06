# Path Update: SecretsBackup2025

## What Changed

Updated all references from old path to new path:
- **Old**: `/mnt/ugreen-nas/Coding/SSH_Key_Backup_2025/`
- **New**: `/mnt/ugreen-nas/Coding/SecretsBackup2025/`

## Files Updated

Total: **55 references** across **12 files**

### Configuration Files
- `config.nix` - Main configuration paths
- `secrets.nix` - Legacy configuration paths
- `modules/core/mpc-secrets.nix` - Secrets module
- `modules/core/samba.nix` - Samba credentials path
- `modules/home/key-backup.nix` - Backup script paths
- `modules/home/secrets-loader.nix` - Secrets loader paths

### Scripts
- `scripts/setup-secrets.sh` - Setup script paths

### Documentation
- `docs/ssh-gpg-key-management.md`
- `docs/SECRETS-MIGRATION.md`
- `docs/MIGRATION-TO-CONFIG-NIX.md`
- `docs/CHANGES-KEY-MANAGEMENT.md`
- `docs/SECRETS-SUMMARY.md`
- `docs/EXTERNAL-SECRETS-GUIDE.md`

## Verification

### System Rebuild ✅
```
sudo nixos-rebuild switch --flake .#wsl
```

Output confirms:
- ✅ External secrets directory accessible
- ✅ Samba credentials cached
- ✅ User password file found

### Secrets Loaded ✅
```bash
# Environment secrets
ls ~/.secrets/env-secrets.sh  # ✅ Exists

# Samba credentials  
sudo cat /root/.secrets/samba-credentials  # ✅ Valid

# GPG agent config
cat ~/.gnupg/gpg-agent.conf  # ✅ Configured
```

### Backup Timer ✅
```bash
systemctl --user status backup-keys.timer
# Status: active (waiting)
# Next run: Mon 2026-02-09 00:00:00
```

## Directory Structure

```
/mnt/ugreen-nas/Coding/SecretsBackup2025/
├── .ssh/                          # SSH keys
│   ├── id_ed25519_github
│   ├── id_ed25519_proxmox
│   └── id_ed25519_proxmox_terraform
├── .gnupg/                        # GPG keyring
│   ├── private-keys-v1.d/
│   └── trustdb.gpg
├── .config/gh/                    # GitHub CLI auth
│   └── hosts.yml
├── .secrets/                      # Sensitive credentials
│   ├── user-password-hash         # User login hash
│   ├── samba-credentials          # Samba mount creds
│   └── env-secrets.sh             # API keys & tokens
├── privatekey.asc                 # GPG private key backup
└── publickey.asc                  # GPG public key backup
```

## No Action Required

The path update is complete and verified. All systems functioning normally:

- ✅ Secrets loading from new path
- ✅ Backup timer using new path
- ✅ All modules updated
- ✅ Documentation updated
- ✅ System rebuilt successfully

## Future Reference

When referencing secrets in documentation or configuration:
- Use: `/mnt/ugreen-nas/Coding/SecretsBackup2025/`
- Not: `/mnt/ugreen-nas/Coding/SSH_Key_Backup_2025/`

---

**Status**: ✅ Complete
**Updated**: 2026-02-05
**Verified**: All systems operational

## Additional Fix: Deprecation Warning

### Issue
```
warning: `programs.zsh.initExtra` is deprecated, use `programs.zsh.initContent` instead.
```

### Resolution
Updated `modules/home/secrets-loader.nix`:
- Changed `programs.zsh.initExtra` → `programs.zsh.initContent` ✅
- Kept `programs.bash.initExtra` (not deprecated yet)

### Verification
```bash
sudo nixos-rebuild switch --flake .#wsl
# ✅ No deprecation warnings
# ✅ Build successful
# ✅ Secrets still loading correctly
```

---

**All Issues Resolved**: ✅ Complete
**Last Updated**: 2026-02-05 17:20
