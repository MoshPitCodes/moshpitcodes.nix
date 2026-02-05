# Key Management Security Improvements

## Summary

Implemented automated key backup and improved secret management for SSH, GPG, and Samba credentials.

## Changes Made

### 1. Automated Key Backup ✅

**File**: `modules/home/key-backup.nix`

Created a systemd timer that automatically backs up SSH and GPG keys to the NAS weekly.

**Features**:
- Runs every Monday at 00:00
- Backs up: `~/.ssh/`, `~/.gnupg/`, `~/.config/gh/`
- Uses rsync with proper exclusions (locks, temps, config files)
- Sets correct permissions on backup
- Fails gracefully if NAS is not mounted

**Usage**:
```bash
# Manual backup
backup-keys

# Check backup status
backup-keys-status

# Check timer schedule
systemctl --user list-timers | grep backup
```

**Location on NAS**: `/mnt/ugreen-nas/Coding/SecretsBackup2025/`

---

### 2. Samba Credentials Security ✅

**Files**: `secrets.nix`, `modules/core/samba.nix`

Moved Samba password out of `secrets.nix` and into an external credentials file on the NAS.

**Before**:
```nix
samba = {
  username = "moshpithome";
  password = "plaintext-password-here";  # ❌ Insecure
  domain = "WORKGROUP";
};
```

**After**:
```nix
samba = {
  username = "moshpithome";
  password = "";  # Empty, uses credentialsFile instead
  domain = "WORKGROUP";
  credentialsFile = "/mnt/ugreen-nas/Coding/SecretsBackup2025/.secrets/samba-credentials";
};
```

**Credentials file location**: `/mnt/ugreen-nas/Coding/SecretsBackup2025/.secrets/samba-credentials`

**Format**:
```
username=moshpithome
password=your-password-here
domain=WORKGROUP
```

**Permissions**: `600` (owner read/write only)

---

### 3. 1Password GPG Integration ✅ (Optional)

**File**: `modules/home/gpg-1password.nix`

Created an optional module that integrates 1Password for automatic GPG passphrase retrieval.

**Status**: Module created but **NOT enabled by default**

**To enable**, see: `docs/SETUP-1PASSWORD-GPG.md`

**Benefits**:
- No manual passphrase entry during commit signing
- Passphrase stored securely in 1Password
- Works with 1Password's biometric unlock
- Easy to enable/disable

---

## File Changes

### New Files
- ✅ `modules/home/key-backup.nix` - Automated backup systemd timer
- ✅ `modules/home/gpg-1password.nix` - 1Password GPG integration (optional)
- ✅ `docs/ssh-gpg-key-management.md` - Comprehensive key management docs
- ✅ `docs/SETUP-1PASSWORD-GPG.md` - Quick setup guide for 1Password
- ✅ `docs/CHANGES-KEY-MANAGEMENT.md` - This file
- ✅ `/mnt/ugreen-nas/Coding/SecretsBackup2025/.secrets/samba-credentials` - Samba password

### Modified Files
- ✅ `modules/home/default.wsl.nix` - Added key-backup.nix and gpg.nix imports
- ✅ `modules/core/samba.nix` - Support external credentials file
- ✅ `secrets.nix` - Removed plaintext Samba password, added credentialsFile reference

---

## Testing

### Key Backup Timer
```bash
# Check timer is active
systemctl --user list-timers | grep backup
# Output: Mon 2026-02-09 00:00:00 CET ... backup-keys.timer

# Check timer status
systemctl --user status backup-keys.timer
# Output: active (waiting) ... Trigger: Mon 2026-02-09

# Test manual backup
backup-keys
# Check: ls -la /mnt/ugreen-nas/Coding/SecretsBackup2025/
```

### Samba Credentials
```bash
# Verify credentials file exists
sudo cat /root/.secrets/samba-credentials
# Output: username=moshpithome, password=..., domain=WORKGROUP

# Test NAS mount
mount | grep ugreen
# Output: systemd-1 on /mnt/ugreen-nas type autofs ...
```

### GPG Signing
```bash
# Test GPG signing (will prompt for passphrase)
echo "test" | gpg --clearsign

# Check passphrase caching (8 hours)
cat ~/.gnupg/gpg-agent.conf | grep cache-ttl
# Output: default-cache-ttl 28800
```

---

## Security Improvements

| Before | After | Improvement |
|--------|-------|-------------|
| No automated backup | Weekly automated backup | ✅ Data protection |
| Plaintext password in secrets.nix | External credentials file | ✅ Reduced exposure |
| Manual key management | Automated with systemd | ✅ Reliability |
| Constant GPG prompts | 8-hour cache (optional 1Password) | ✅ Usability |

---

## Remaining Recommendations

1. **Secret Encryption** (Not implemented)
   - Consider `agenix` or `sops-nix` for encrypting secrets.nix
   - Would encrypt API keys, WiFi passwords, etc.

2. **Key Rotation** (Not implemented)
   - No automatic key expiration/rotation policy
   - Manually rotate keys annually

3. **Backup Verification** (Future enhancement)
   - Add backup integrity checks
   - Send notifications on backup success/failure

4. **Multi-Machine Sync** (Future enhancement)
   - Consider syncthing for real-time key sync
   - Currently uses NAS as central source

---

## Rollback Instructions

If you need to revert these changes:

```bash
# 1. Remove new modules from imports
# Edit modules/home/default.wsl.nix and remove:
#   ./key-backup.nix
#   ./gpg-1password.nix (if added)

# 2. Restore plaintext Samba password (if needed)
# Edit secrets.nix:
samba = {
  username = "moshpithome";
  password = "your-password-here";
  domain = "WORKGROUP";
};

# 3. Rebuild
sudo nixos-rebuild switch --flake .#wsl --impure

# 4. Stop backup timer (optional)
systemctl --user stop backup-keys.timer
systemctl --user disable backup-keys.timer
```

---

## Related Documentation

- Full key management guide: `docs/ssh-gpg-key-management.md`
- 1Password setup (optional): `docs/SETUP-1PASSWORD-GPG.md`
- Original 1Password guide: `docs/gpg-1password-integration.md`

---

## Commit Message

```
feat(security): Improve key management and secret handling

- Add automated weekly backup of SSH/GPG keys to NAS
- Move Samba password from secrets.nix to external file
- Add optional 1Password GPG passphrase integration
- Improve GPG agent configuration for WSL

Fixes: Constant GPG password prompting in WSL
See: docs/CHANGES-KEY-MANAGEMENT.md
```
