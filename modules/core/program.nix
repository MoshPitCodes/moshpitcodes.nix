{ pkgs, ... }:
{
  programs = {
    dconf.enable = true;
    zsh.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = false; # Use GNOME keyring for SSH instead
      pinentryPackage = pkgs.pinentry-gnome3;
    };
    nix-ld = {
      enable = true;
      libraries = with pkgs; [ ];
    };
  };
}
