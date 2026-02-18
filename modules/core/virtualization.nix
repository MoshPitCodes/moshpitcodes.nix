# Virtualization: libvirt, Docker, SPICE
{
  lib,
  pkgs,
  username,
  ...
}:
{
  # Add user to virtualization groups
  users.users.${username}.extraGroups = lib.mkAfter [
    "libvirtd"
    "kvm"
  ];

  # System-level virtualization support libraries
  environment.systemPackages = with pkgs; [
    spice
    spice-gtk
    spice-protocol
    virtio-win
    win-spice
    docker-compose
  ];

  # Manage the virtualisation services
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu.swtpm.enable = true;
    };
    docker = {
      enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };
    spiceUSBRedirection.enable = true;
  };

  services.spice-vdagentd.enable = true;
}
