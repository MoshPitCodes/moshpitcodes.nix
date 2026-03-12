# Network configuration
{ lib, ... }:
{
  networking = {
    networkmanager.enable = true;

    # Firewall configuration
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
      allowedUDPPorts = [ ];
    };

    # Static /etc/hosts entries
    hosts = {
      "192.168.178.50" = [
        "adguard.home.arpa"
        "arcane.home.arpa"
        "caddy.home.arpa"
        "grafana.home.arpa"
        "homepage.home.arpa"
        "prometheus.home.arpa"
      ];
    };

    # DNS servers
    nameservers = [
      "8.8.8.8"
      "8.8.4.4"
      "1.1.1.1"
    ];
  };
}
