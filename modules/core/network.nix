{ pkgs, host, ... }:
{
  networking = {
    hostName = "${host}";
    networkmanager.enable = true;
    nameservers = [
      "8.8.8.8"
      "8.8.4.4"
      "1.1.1.1"
    ];
    wireless.networks = {
      "<SSID>" = { # replace with actual SSID
         psk = throw "<Enter Wi-Fi password in ./modules/core/network.nix>"; # replace with actual password
      };
    };
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
