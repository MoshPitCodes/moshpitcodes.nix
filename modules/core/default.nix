# Core NixOS modules aggregator
{ ... }:
{
  imports = [
    ./bootloader.nix
    ./system.nix
    ./network.nix
    ./security.nix
    ./services.nix
    ./pipewire.nix
    ./wayland.nix
    ./display-manager.nix
    ./fonts.nix
    ./user.nix

    # Programs and hardware
    ./program.nix
    ./hardware.nix
    ./xserver.nix
    ./virtualization.nix

    # Host-specific modules (import in host config, not here):
    # ./samba.nix
    # ./steam.nix
    # ./flatpak.nix
    # ./vm-overrides.nix (imported by hosts/vmware-guest/default.nix)
  ];
}
