{
  pkgs,
  ...
}:
{
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      flake-registry = builtins.toFile "null-flake-registry.json" ''{"flakes":[],"version":2}'';

      # Binary caches for faster builds (supplements default cache.nixos.org)
      # nix-community: Home-manager, NUR, community packages
      # nix-gaming: Gaming optimizations, Proton, Wine
      # hyprland: Hyprland compositor pre-built binaries
      # ghostty: Ghostty terminal emulator
      extra-substituters = [
        "https://nix-community.cachix.org"
        "https://nix-gaming.cachix.org"
        "https://hyprland.cachix.org"
        "https://ghostty.cachix.org"
      ];

      extra-trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "ghostty.cachix.org-1:QB389yTa6gTyneehvqG58y0WnHjQOqgnA+wBnpWWxns="
      ];

      trusted-users = [ "@wheel" ];

      warn-dirty = false;
    };
  };
  # NUR overlay is applied centrally via overlays/default.nix

  # Note: security.sudo.enable is set in security.nix

  environment.systemPackages = with pkgs; [
    git
  ];

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.05";
}
