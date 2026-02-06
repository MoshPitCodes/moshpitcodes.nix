{
  pkgs,
  lib,
  config,
  customsecrets,
  ...
}:

{
  # Enable CIFS/SMB filesystem support
  boot.supportedFilesystems = [ "cifs" ];

  # Install required packages for CIFS/SMB mounting
  environment.systemPackages = with pkgs; [
    cifs-utils # Tools for mounting CIFS/SMB shares
  ];

  # Open firewall ports for Samba/CIFS (optional, only if hosting)
  # For client-only usage, these are not strictly necessary
  # networking.firewall.allowedTCPPorts = [ 139 445 ];
  # networking.firewall.allowedUDPPorts = [ 137 138 ];

  # Enable Avahi for service discovery (optional, helps with hostname resolution)
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

  # Create the mount point directory
  # This ensures /mnt/ugreen-nas exists with proper permissions
  systemd.tmpfiles.rules = [
    "d /mnt/ugreen-nas 0755 root root -"
  ];

  # Create credentials file from secrets at activation time
  # Uses a systemd credential approach to minimize store exposure:
  # - The script itself contains the credentials (unavoidable with --impure secrets)
  # - File permissions are locked down immediately after creation
  # - For production-grade secrets management, consider migrating to agenix or sops-nix
  system.activationScripts.sambaCredentials = lib.mkIf (customsecrets ? samba) {
    deps = [ "specialfs" ];
    text =
      let
        sambaUser = customsecrets.samba.username or "";
        sambaPass = customsecrets.samba.password or "";
        sambaDomain = customsecrets.samba.domain or "WORKGROUP";
      in
      ''
        # Create credentials directory with restricted permissions
        install -d -m 0700 /root/.secrets

        # Write credentials file atomically via temp file to avoid partial reads
        tmpfile=$(mktemp /root/.secrets/.samba-credentials.XXXXXX)
        chmod 600 "$tmpfile"
        printf 'username=%s\npassword=%s\ndomain=%s\n' \
          '${sambaUser}' '${sambaPass}' '${sambaDomain}' > "$tmpfile"
        mv -f "$tmpfile" /root/.secrets/samba-credentials
      '';
  };
}
