# UGREEN NAS SMB/CIFS Mount Setup

## Configuration Overview

The NixOS system has been configured to mount your UGREEN NAS (DH2300-5EDE) via SMB/CIFS.

### Files Modified/Created

1. **`/home/moshpitcodes/moshpitcodes.nix/modules/core/samba.nix`** (NEW)
   - Enables CIFS filesystem support
   - Installs `cifs-utils`
   - Configures Avahi for network discovery
   - Creates mount point directory
   - Sets up secure credentials file from secrets

2. **`/home/moshpitcodes/moshpitcodes.nix/modules/core/default.nix`** (MODIFIED)
   - Added `./samba.nix` to imports

3. **`/home/moshpitcodes/moshpitcodes.nix/hosts/laptop/hardware-configuration.nix`** (MODIFIED)
   - Added CIFS mount configuration for `/mnt/ugreen-nas`

## Configuration Details

### Mount Configuration

- **NAS IP:** `192.168.178.144`
- **Mount Point:** `/mnt/ugreen-nas`
- **Share Path:** `//192.168.178.144/share`
- **Credentials:** `/root/.secrets/samba-credentials` (generated from `secrets.nix`)

### Mount Options

- **Automount:** The share will automount when you access `/mnt/ugreen-nas`
- **Idle Timeout:** Automatically unmounts after 5 minutes of inactivity
- **Protocol:** SMB 3.0 (can be adjusted if compatibility issues occur)
- **Permissions:** Files are `0755` (rwxr-xr-x), directories are `0755`
- **User/Group:** Files are owned by UID 1000, GID 100 (your user)

## Prerequisites - Update secrets.nix

Your `secrets.nix` file needs to include Samba credentials:

```nix
{
  # ... other config ...

  samba = {
    username = "your-nas-username";
    password = "your-nas-password";
  };
}
```

**IMPORTANT:** According to the NAS UI instructions, the login format is:
- Format: `domain name\account number + password`
- Example: If your account is `xiaoming` on domain `ABC`, use:
  - Username: `ABC\xiaoming`
  - Password: Your password

## Rebuild and Activate

After updating your `secrets.nix`, rebuild your NixOS configuration:

```bash
# Rebuild the system
sudo nixos-rebuild switch --flake .#laptop

# Or if using nh (if installed)
nh os switch
```

## Testing the Mount

After rebuilding:

```bash
# Check if the automount unit is active
systemctl status mnt-ugreen\\x2dnas.automount

# Access the mount point (this will trigger automount)
cd /mnt/ugreen-nas
ls -la

# Check if the mount is active
mount | grep ugreen

# View mount details
systemctl status mnt-ugreen\\x2dnas.mount
```

## Troubleshooting

### Issue: Mount fails or shows empty directory

1. **Check credentials file:**
   ```bash
   sudo cat /root/.secrets/samba-credentials
   ```
   Should show your username and password.

2. **Verify network connectivity:**
   ```bash
   ping 192.168.178.144
   ```

3. **Test manual mount:**
   ```bash
   sudo mount -t cifs //192.168.178.144/share /mnt/test \
     -o credentials=/root/.secrets/samba-credentials,uid=1000,gid=100,vers=3.0
   ```

4. **Check systemd mount unit logs:**
   ```bash
   journalctl -u mnt-ugreen-nas.mount -f
   journalctl -u mnt-ugreen-nas.automount -f
   ```

5. **Verify CIFS module is loaded:**
   ```bash
   lsmod | grep cifs
   cat /proc/filesystems | grep cifs
   ```

### Issue: Wrong share path

If `//192.168.178.144/share` is not the correct path, you need to find the actual share name:

```bash
# List available shares (after installing smbclient)
nix-shell -p samba --run "smbclient -L //192.168.178.144 -U 'username%password'"
```

Then update the `device` in `/home/moshpitcodes/moshpitcodes.nix/hosts/laptop/hardware-configuration.nix`:
```nix
device = "//192.168.178.144/actual-share-name";
```

### Issue: Permission denied

The mount uses `uid=1000` and `gid=100`. Verify your user ID:

```bash
id -u  # Should show 1000
id -g  # Should show your group ID
```

If different, update the mount options in `hardware-configuration.nix`:
```nix
"uid=YOUR_UID"
"gid=YOUR_GID"
```

### Issue: SMB version incompatibility

If the mount fails with protocol errors, try different SMB versions:

In `hardware-configuration.nix`, change:
```nix
"vers=3.0"  # Try 3.1.1, 3.0, 2.1, or 2.0
```

Common versions:
- `3.1.1` - Latest, most secure
- `3.0` - Good balance of compatibility and security
- `2.1` - Older but widely supported
- `2.0` - Fallback for very old NAS devices

## Security Notes

- Credentials are stored in `/root/.secrets/samba-credentials` (mode 600, root only)
- Credentials are generated during system activation from `secrets.nix`
- `secrets.nix` is git-ignored and never enters the Nix store
- The mount uses `nofail` option so boot won't fail if NAS is unavailable

## Accessing from File Manager

Once mounted, you can access the share from your file manager:
- Path: `/mnt/ugreen-nas`
- The automount will activate when you browse to this location

## Advanced Configuration

### Adjust Share Path

If you need to mount a different share or subdirectory, edit:
`/home/moshpitcodes/moshpitcodes.nix/hosts/laptop/hardware-configuration.nix`

```nix
device = "//192.168.178.144/different-share";
# or with subdirectory
device = "//192.168.178.144/share/subfolder";
```

### Multiple Shares

To mount multiple shares from the same NAS, add additional `fileSystems` entries:

```nix
fileSystems."/mnt/ugreen-nas-backup" = {
  device = "//192.168.178.144/backup";
  fsType = "cifs";
  options = [
    "credentials=/root/.secrets/samba-credentials"
    # ... same options as main mount ...
  ];
};
```

### Performance Tuning

For better performance over a fast local network:

```nix
"rsize=1048576"   # 1MB read buffer
"wsize=1048576"   # 1MB write buffer
"cache=strict"    # Stricter caching for data integrity
```

For slower networks or WiFi:
```nix
"rsize=65536"     # 64KB read buffer
"wsize=65536"     # 64KB write buffer
"cache=loose"     # More aggressive caching
```

## References

- [NixOS Manual - CIFS Filesystems](https://nixos.org/manual/nixos/stable/#sec-cifs-filesystems)
- [Linux CIFS Mount Options](https://linux.die.net/man/8/mount.cifs)
- [Systemd Mount Unit Options](https://www.freedesktop.org/software/systemd/man/systemd.mount.html)
