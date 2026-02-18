# WSL core imports (no pipewire, no steam, no samba, no wayland)
{ ... }:
{
  imports = [
    ./bootloader.nix
    ./system.nix
    ./network.nix
    ./security.nix
    ./services.nix
    ./fonts.nix
    ./user.nix
    ./program.nix
    ./wsl-overrides.nix
  ];
}
