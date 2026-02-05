{ pkgs, ... }:
{
  # System packages needed for GPG
  environment.systemPackages = with pkgs; [
    pinentry-curses # Terminal-based pinentry for GPG
    gnupg # Ensure GPG is in system packages
  ];

  programs = {
    dconf.enable = true;
    zsh.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = false;
      pinentryPackage = pkgs.pinentry-curses;
    };
    nix-ld = {
      enable = true;
      libraries = with pkgs; [ ];
    };
  };
}
