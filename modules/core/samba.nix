{ pkgs, lib, config, customsecrets, ... }:

{
  # Enable CIFS/SMB filesystem support
  boot.supportedFilesystems = [ "cifs" ];

  # Install required packages for CIFS/SMB mounting
  environment.systemPackages = with pkgs; [
    cifs-utils  # Tools for mounting CIFS/SMB shares
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
  # This keeps credentials secure and out of the Nix store
  system.activationScripts.sambaCredentials = lib.mkIf (customsecrets ? samba) {
    text = ''
      # Create credentials directory if it doesn't exist
      mkdir -p /root/.secrets
      chmod 700 /root/.secrets

      # Write credentials file securely
      cat > /root/.secrets/samba-credentials << EOF
username=${customsecrets.samba.username or ""}
password=${customsecrets.samba.password or ""}
EOF
      chmod 600 /root/.secrets/samba-credentials
    '';
  };
}
