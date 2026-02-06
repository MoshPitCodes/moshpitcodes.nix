{
  lib,
  pkgs,
  username,
  ...
}:
{
  # Add user to libvirtd and kvm groups (merged with existing groups from user.nix)
  users.users.${username}.extraGroups = lib.mkAfter [
    "libvirtd"
    "kvm"
  ];

  # System-level virtualization support libraries
  # GUI tools (virt-manager, virt-viewer) and Docker CLI tools are in home-manager
  environment.systemPackages = with pkgs; [
    spice
    spice-gtk
    spice-protocol
    virtio-win
    win-spice
  ];

  # Manage the virtualisation services
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
      };
    };
    docker.enable = true;
    spiceUSBRedirection.enable = true;
  };
  services.spice-vdagentd.enable = true;
}
