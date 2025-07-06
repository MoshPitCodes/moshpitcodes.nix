{ pkgs, host, customsecrets, ... }:
{
  networking = {
    hostName = "${host}";
    networkmanager.enable = true;
    nameservers = [
      "8.8.8.8"
      "8.8.4.4"
      "1.1.1.1"
    ];
    wireless.networks =
      if customsecrets.network.wifiSSID != "" then {
        "${customsecrets.network.wifiSSID}" = {
          psk = customsecrets.network.wifiPassword;
        };
      } else {};
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22
        80
        443
        59010
        59011
      ];
      allowedUDPPorts = [
        59010
        59011
      ];
    };
  };

  environment.systemPackages = with pkgs; [ networkmanagerapplet ];
}
