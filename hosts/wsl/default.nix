{ config, pkgs, ... }:

{
  imports = [
    ../modules/core/default.nix
    # Potentially, home-manager modules could be imported here
    # For example:
    # ../modules/home/default.desktop.nix
  ];

  # WSL-specific configuration
  wsl.enable = true;
  wsl.defaultUser = config.users.users.moshpit.name;
  wsl.wslConf.automount.root = "/mnt";
  wsl.startMenuLaunchers = true;

  # Basic system settings
  networking.hostName = "nixos-wsl";
  system.stateVersion = "23.11"; # Or your desired version
}
