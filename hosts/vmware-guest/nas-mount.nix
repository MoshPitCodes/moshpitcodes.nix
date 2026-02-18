# VMware shared folder mount for NAS
# VMware Tools automatically mounts shared folders to /mnt/hgfs/
{ lib, pkgs, ... }:
{
  # VMware shared folders are automatically mounted by vmware-tools
  # The path will be /mnt/hgfs/<shared-folder-name>

  # Ensure the mount point exists and has correct permissions
  systemd.tmpfiles.rules = [
    "d /mnt/hgfs 0755 root root -"
  ];

  # VMware tools handles mounting, but we can ensure it's enabled
  # The vmware.guest.enable in default.nix enables vmware-vmblock-fuse
  # which provides the shared folder functionality

  # Note: Set customsecrets.backup.nasBackupPath in secrets.nix to:
  # "/mnt/hgfs/<your-shared-folder-name>/backups"
}
