{
  pkgs,
  lib,
  config,
  customsecrets,
  mpcConfig ? { },
  ...
}:
let
  # Get credentials file path from mpcConfig (preferred) or customsecrets
  externalCredentialsFile =
    if
      (mpcConfig ? external)
      && (mpcConfig.external ? sambaCredentials)
      && (mpcConfig.external.sambaCredentials != "")
    then
      mpcConfig.external.sambaCredentials
    else
      customsecrets.samba.credentialsFile or "";

  # Get samba username/domain from mpcConfig (preferred) or customsecrets
  sambaUsername = mpcConfig.samba.username or customsecrets.samba.username or "guest";
  sambaDomain = mpcConfig.samba.domain or customsecrets.samba.domain or "WORKGROUP";
in
{
  # Enable CIFS/SMB filesystem support
  boot.supportedFilesystems = [ "cifs" ];

  # Install required packages for CIFS/SMB mounting
  environment.systemPackages = with pkgs; [
    cifs-utils # Tools for mounting CIFS/SMB shares
  ];

  # Enable Avahi for service discovery (helps with hostname resolution)
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
  systemd.tmpfiles.rules = [
    "d /mnt/ugreen-nas 0755 root root -"
  ];

  # Create credentials file from external source at activation time
  # Priority:
  #   1. Copy from external file (mpcConfig.external.sambaCredentials)
  #   2. Generate from mpcConfig.samba settings (username/domain only, no password)
  #   3. Skip if neither is configured
  system.activationScripts.sambaCredentials = {
    deps = [ "specialfs" ];
    text = ''
      # Create credentials directory
      mkdir -p /root/.secrets
      chmod 700 /root/.secrets

      EXTERNAL_CREDS="${externalCredentialsFile}"
      LOCAL_CREDS="/root/.secrets/samba-credentials"

      # Option 1: Copy from external source (preferred - contains password)
      if [[ -n "$EXTERNAL_CREDS" && -f "$EXTERNAL_CREDS" ]]; then
        cp "$EXTERNAL_CREDS" "$LOCAL_CREDS"
        chmod 600 "$LOCAL_CREDS"
        echo "Samba credentials copied from: $EXTERNAL_CREDS"
      # Option 2: Use cached credentials if available
      elif [[ -f "$LOCAL_CREDS" ]]; then
        echo "Using cached samba credentials (external source not available)"
      # Option 3: No credentials available - mount will fail
      else
        echo "WARNING: No samba credentials available"
        echo "Expected credentials file at: $EXTERNAL_CREDS"
        echo "Create it with format:"
        echo "  username=${sambaUsername}"
        echo "  password=YOUR_PASSWORD"
        echo "  domain=${sambaDomain}"
      fi
    '';
  };
}
