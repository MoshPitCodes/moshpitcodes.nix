# Template for NAS mount configuration (for desktop/laptop hosts)
# Copy this to hosts/<hostname>/nas-mount.nix and configure for your setup

{
  lib,
  pkgs,
  customsecrets,
  ...
}:
let
  # NAS mount configuration from secrets
  nasHost = customsecrets.nas.host or "";
  nasShare = customsecrets.nas.share or "";
  nasUsername = customsecrets.nas.username or "";
  nasPassword = customsecrets.nas.password or "";
  mountPoint = "/mnt/nas";

  # Only enable if NAS is configured
  hasNasConfig = nasHost != "" && nasShare != "";
in
{
  # SMB/CIFS mount configuration for network NAS
  # This is for desktop/laptop hosts that access NAS over the network

  # Ensure mount point exists
  systemd.tmpfiles.rules = lib.mkIf hasNasConfig [
    "d ${mountPoint} 0755 root root -"
  ];

  # Create credentials file for SMB mount
  environment.etc."nas-credentials" = lib.mkIf hasNasConfig {
    text = ''
      username=${nasUsername}
      password=${nasPassword}
    '';
    mode = "0600";
  };

  # NAS mount via systemd
  systemd.mounts = lib.mkIf hasNasConfig [
    {
      description = "NAS SMB/CIFS Mount";
      what = "//${nasHost}/${nasShare}";
      where = mountPoint;
      type = "cifs";
      options = "credentials=/etc/nas-credentials,uid=1000,gid=100,file_mode=0644,dir_mode=0755,vers=3.0";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      requires = [ "network-online.target" ];
    }
  ];

  # Auto-mount on access
  systemd.automounts = lib.mkIf hasNasConfig [
    {
      description = "NAS Auto-mount";
      where = mountPoint;
      wantedBy = [ "multi-user.target" ];
    }
  ];

  # Required packages for CIFS mounting
  environment.systemPackages = lib.mkIf hasNasConfig [ pkgs.cifs-utils ];

  # Note: In secrets.nix, add:
  # nas = {
  #   host = "your-nas-ip-or-hostname";
  #   share = "share-name";
  #   username = "your-username";
  #   password = "your-password";
  # };
  #
  # And set backup path to:
  # backup.nasBackupPath = "/mnt/nas/backups";
}
