{ pkgs, host, customsecrets, lib, config, ... }:

{
  networking = {
    hostName = host;

    networkmanager.enable = true;

    # Explicitly disable Wi-Fi in WSL
    wireless.enable = !config.wsl.enable;

    # Only define Wi-Fi networks on non-WSL systems
    wireless.networks = lib.mkIf (!config.wsl.enable) (
      if customsecrets.network.wifiSSID != "" then {
        "${customsecrets.network.wifiSSID}" = {
          psk = customsecrets.network.wifiPassword;
        };
      } else {}
    );

    nameservers = [
      "8.8.8.8"
      "8.8.4.4"
      "1.1.1.1"
    ];

    firewall = {
      enable = true;
      allowedTCPPorts = [
        22   # SSH
        80   # HTTP
        443  # HTTPS
      ];
      allowedUDPPorts = [ ];
    };
  };

  environment.systemPackages = with pkgs; [
    networkmanagerapplet
  ];
}
