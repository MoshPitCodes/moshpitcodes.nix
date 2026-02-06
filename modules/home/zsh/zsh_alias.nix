{
  customsecrets,
  ...
}:
{
  # Shell Aliases
  #
  # Note: Additional aliases are defined in their respective modules:
  # - Git aliases: modules/home/git.nix
  # - Development tool aliases (opencode-setup, opencode-doppler): modules/home/development/development.nix
  # - Claude Code aliases (claude-code-setup, claude-code-auth-doppler): modules/home/development/claude-code.nix (if enabled)

  programs.zsh = {
    shellAliases = {
      # Utils
      c = "clear";
      cd = "z";
      tt = "gtrash put";
      cat = "bat";
      nano = "micro";
      code = "codium";
      diff = "delta --diff-so-fancy --side-by-side";
      less = "bat";
      y = "yazi";
      py = "python";
      ipy = "ipython";
      icat = "viu"; # Terminal image viewer (replaced kitten icat)
      dsize = "du -hs";
      pdf = "tdf";
      open = "xdg-open";
      space = "ncdu";
      man = "BAT_THEME='rose-pine' batman";

      l = "eza --icons  -a --group-directories-first -1"; # EZA_ICON_SPACING=2
      ll = "eza --icons  -a --group-directories-first -1 --long --no-user";
      tree = "eza --icons --tree --group-directories-first";

      # Nixos
      cdnix = "cd ~/${customsecrets.reponame} && codium ~/${customsecrets.reponame}";
      ns = "nom-shell --run zsh";
      nd = "nom develop --command zsh";
      nb = "nom build";
      nix-switch = "sudo nixos-rebuild switch --flake .";
      nix-test = "sudo nixos-rebuild test --flake .";
      nix-update = "nix flake update";
      nix-clean = "sudo nix-collect-garbage -d";
      nix-search = "nix search nixpkgs";

      # python
      piv = "python -m venv .venv";
      psv = "source .venv/bin/activate";
    };
  };
}
