{ pkgs, ... }:
{
  programs = {
    dconf.enable = true;
    zsh.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = false; # GNOME Keyring handles SSH on all hosts
      pinentryPackage = pkgs.pinentry-gnome3;
      settings = {
        # Cache GPG passphrases for 8 hours (development sessions)
        default-cache-ttl = 28800;
        max-cache-ttl = 28800;
      };
    };
    nix-ld = {
      enable = true;
      libraries = with pkgs; [ ];
    };
  };
}
