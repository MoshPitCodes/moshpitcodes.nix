# UGREEN NAS Quick Start Guide

## Immediate Next Steps

### 1. Update Your secrets.nix

Edit `/home/moshpitcodes/moshpitcodes.nix/secrets.nix` and add your Samba credentials:

```nix
{
  # ... your existing config ...

  samba = {
    username = "YOUR_DOMAIN\\YOUR_USERNAME";  # e.g., "ABC\\xiaoming"
    password = "YOUR_PASSWORD";               # e.g., "Aa123456"
  };
}
```

**Important:** According to your NAS UI:
- Use format: `domain\username` (e.g., `ABC\xiaoming`)
- In Nix strings, backslash must be escaped: `"ABC\\xiaoming"`

### 2. Find Your Actual Share Name

Before rebuilding, you should verify the share name. The configuration currently uses `//192.168.178.144/share` but this might not be correct.

```bash
# Install smbclient temporarily
nix-shell -p samba

# List available shares (replace with your credentials)
smbclient -L //192.168.178.144 -U 'DOMAIN\username%password'
```

Example output:
```
Sharename       Type      Comment
---------       ----      -------
Public          Disk      Public folder
Media           Disk      Media storage
backup          Disk      Backup folder
```

If the share name is different from `share`, update this line in:
`/home/moshpitcodes/moshpitcodes.nix/hosts/laptop/hardware-configuration.nix`

```nix
device = "//192.168.178.144/YOUR_ACTUAL_SHARE_NAME";
```

### 3. Rebuild Your System

```bash
# Navigate to your flake directory
cd /home/moshpitcodes/moshpitcodes.nix

# Rebuild (will take a few minutes)
sudo nixos-rebuild switch --flake .#laptop

# Or if you have nh installed:
nh os switch
```

### 4. Test the Mount

```bash
# Check automount status
systemctl status mnt-ugreen\\x2dnas.automount

# Access the mount point (triggers automount)
cd /mnt/ugreen-nas
ls -la

# Verify mount is active
mount | grep ugreen-nas

# Check logs if issues
journalctl -u mnt-ugreen-nas.mount -n 50
```

## Common Issues & Quick Fixes

### Issue: "Permission denied" or "Access denied"

**Check credentials:**
```bash
sudo cat /root/.secrets/samba-credentials
```

Should show:
```
username=DOMAIN\username
password=yourpassword
```

If incorrect, update `secrets.nix` and rebuild.

### Issue: "Host is down" or "Network unreachable"

**Check network connectivity:**
```bash
ping 192.168.178.144
```

Make sure you're on the same network as the NAS.

### Issue: "No such file or directory" for share

**Wrong share name.** Follow step 2 above to find the correct share name.

### Issue: "Protocol negotiation failed"

**Try different SMB version.** Edit in `hardware-configuration.nix`:
```nix
"vers=3.0"  # Try changing to: 2.1, 2.0, or 3.1.1
```

Then rebuild.

## Testing Different Share Paths

If you're not sure which share to use, try mounting manually first:

```bash
# Create test mount point
sudo mkdir -p /mnt/test

# Try different shares (replace USERNAME and PASSWORD)
sudo mount -t cifs //192.168.178.144/share /mnt/test \
  -o username='DOMAIN\username',password='password',vers=3.0

# Check contents
ls /mnt/test

# Unmount
sudo umount /mnt/test
```

Once you find the right share, update `hardware-configuration.nix` accordingly.

## Files Changed

All changes are in git staging area and ready to commit:

1. **`SAMBA_SETUP.md`** (NEW) - Comprehensive setup guide
2. **`modules/core/samba.nix`** (NEW) - Samba/CIFS module
3. **`modules/core/default.nix`** (MODIFIED) - Added samba module import
4. **`hosts/laptop/hardware-configuration.nix`** (MODIFIED) - Added CIFS mount

## Need Help?

See the full documentation: `SAMBA_SETUP.md`

## Mount Configuration Summary

- **NAS:** 192.168.178.144 (DH2300-5EDE)
- **Mount Point:** `/mnt/ugreen-nas`
- **Type:** Auto-mount (mounts on access, unmounts after 5min idle)
- **Protocol:** SMB 3.0
- **Permissions:** Files/dirs are readable and writable by your user
- **Boot Behavior:** Won't block boot if NAS is unavailable
