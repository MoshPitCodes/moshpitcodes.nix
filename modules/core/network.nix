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
        "arcane.home.arpa"
        "grafana.home.arpa"
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
