{
  lib,
  pkgs,
  username,
  ...
}:
{
  # Add user to libvirtd and kvm groups (merged with existing groups from user.nix)
  users.users.${username}.extraGroups = lib.mkAfter [ "libvirtd" "kvm" ];

  # Install necessary packages
  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
    spice
    spice-gtk
    spice-protocol
    virtio-win
    win-spice
    adwaita-icon-theme
    docker
    docker-compose
    docker-credential-helpers
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
