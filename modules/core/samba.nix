# CIFS/SMB NAS mounts with credential management
{
  pkgs,
  lib,
  customsecrets,
  ...
}:
{
  # Enable CIFS/SMB filesystem support
  boot.supportedFilesystems = [ "cifs" ];

  environment.systemPackages = with pkgs; [
    cifs-utils
  ];

  # Avahi for service discovery / hostname resolution
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      domain = true;
      userServices = true;
    };
  };

  # Create mount point directory
  systemd.tmpfiles.rules = [
    "d /mnt/ugreen-nas 0755 root root -"
  ];

  # Create credentials file from secrets at activation time
  system.activationScripts.sambaCredentials = lib.mkIf (customsecrets ? samba) {
    deps = [ "specialfs" ];
    text =
      let
        sambaUser = customsecrets.samba.username or "";
        sambaPass = customsecrets.samba.password or "";
        sambaDomain = customsecrets.samba.domain or "WORKGROUP";
      in
      ''
        install -d -m 0700 /root/.secrets
        tmpfile=$(mktemp /root/.secrets/.samba-credentials.XXXXXX)
        chmod 600 "$tmpfile"
        printf 'username=%s\npassword=%s\ndomain=%s\n' \
          '${sambaUser}' '${sambaPass}' '${sambaDomain}' > "$tmpfile"
        mv -f "$tmpfile" /root/.secrets/samba-credentials
      '';
  };
}
