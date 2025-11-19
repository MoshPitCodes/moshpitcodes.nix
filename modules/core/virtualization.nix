{
  pkgs,
  username,
  ...
}:
{
  # Add user to libvirtd group
  users.users.${username}.extraGroups = [ "libvirtd" "kvm"];

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
        # ovmf.enable = true; # Removed: All OVMF images are now available by default
        # ovmf.packages = [ pkgs.OVMFFull.fd ]; # Removed: No longer needed
      };
    };
    docker.enable = true;
    spiceUSBRedirection.enable = true;
  };
  services.spice-vdagentd.enable = true;
}
