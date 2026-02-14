{
  host,
  customsecrets,
  lib,
  pkgs,
  config,
  ...
}:

let
  # Check if WSL module is loaded and enabled
  isWsl = config ? wsl && config.wsl.enable;
in
{
  networking = {
    hostName = host;

    networkmanager = {
      enable = true;
      wifi.powersave = false; # Disable WiFi power saving for better stability
    };

    # NetworkManager manages wireless connections, so disable wpa_supplicant
    # (networking.wireless conflicts with NetworkManager)
    wireless.enable = lib.mkForce false;

    nameservers = [
      "8.8.8.8"
      "8.8.4.4"
      "1.1.1.1"
    ];

    firewall = {
      enable = true;
      allowedTCPPorts = [
        22 # SSH
        80 # HTTP
        443 # HTTPS
      ];
      allowedUDPPorts = [ ];
    };
  };

  # networkmanagerapplet is in home/hyprland/hyprland.nix (user-level GUI)

  # Create WiFi connection profile for NetworkManager
  system.activationScripts.setupWifiProfile = lib.mkIf (!isWsl && customsecrets.network.wifiSSID != "") {
    text = ''
      mkdir -p /etc/NetworkManager/system-connections
      cat > /etc/NetworkManager/system-connections/${customsecrets.network.wifiSSID}.nmconnection <<EOF
[connection]
id=${customsecrets.network.wifiSSID}
type=wifi
autoconnect=true
permissions=

[wifi]
mode=infrastructure
ssid=${customsecrets.network.wifiSSID}

[wifi-security]
auth-alg=open
key-mgmt=wpa-psk
psk=${customsecrets.network.wifiPassword}

[ipv4]
method=auto

[ipv6]
addr-gen-mode=default
method=auto
EOF
      chmod 600 /etc/NetworkManager/system-connections/${customsecrets.network.wifiSSID}.nmconnection
    '';
  };
}
