# VMware HGFS (Host Guest File System) shared folder mounting
{ lib, pkgs, ... }:
{
  # Systemd service to mount VMware shared folder
  systemd.services.vmhgfs-mount = {
    description = "Mount VMware HGFS Shared Folder";
    wantedBy = [ "multi-user.target" ];
    after = [ "vmware.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p /mnt/hgfs/Z";
      ExecStart = "${pkgs.open-vm-tools}/bin/vmhgfs-fuse .host:/Z /mnt/hgfs/Z -o allow_other -o uid=1000 -o gid=100 -o umask=022 -o default_permissions";
      ExecStop = "${pkgs.util-linux}/bin/umount /mnt/hgfs/Z";
    };
  };

  # Ensure mount directory exists
  systemd.tmpfiles.rules = [
    "d /mnt/hgfs 0755 root root -"
  ];
}
