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

      # Declaratively configure WiFi networks
      ensureProfiles = {
        environmentFiles = lib.mkIf (!isWsl && customsecrets.network.wifiSSID != "") [
          (pkgs.writeText "wifi-${customsecrets.network.wifiSSID}.nmconnection" ''
            [connection]
            id=${customsecrets.network.wifiSSID}
            type=wifi
            autoconnect=true

            [wifi]
            mode=infrastructure
            ssid=${customsecrets.network.wifiSSID}

            [wifi-security]
            key-mgmt=wpa-psk
            psk=${customsecrets.network.wifiPassword}

            [ipv4]
            method=auto

            [ipv6]
            method=auto
          '')
        ];
      };
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
}
