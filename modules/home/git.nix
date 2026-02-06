{
  lib,
  pkgs,
  customsecrets,
  ...
}:
{
  programs = {
    git = {
      enable = true;

      settings = {
        user = {
          name = customsecrets.git.userName;
          email = customsecrets.git.userEmail;
          inherit (customsecrets.git.user) signingkey;
        };
        init.defaultBranch = "main";
        credential.helper = "${pkgs.git}/lib/git-core/git-credential-libsecret";
        merge.conflictstyle = "diff3";
        diff.colorMoved = "default";
        commit.gpgsign = true;
        gpg.format = "openpgp";
        core.autocrlf = "input";
      };
    };

    delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        line-numbers = true;
        side-by-side = true;
        diff-so-fancy = true;
        navigate = true;

        # Rose Pine color scheme
        syntax-theme = "TwoDark"; # Fallback until bat rose-pine theme is built

        # Rose Pine colors for diff highlighting
        minus-style = "syntax #26233a"; # base with highlight background
        minus-emph-style = "syntax #eb6f92"; # love for deletions
        plus-style = "syntax #26233a"; # base with highlight background
        plus-emph-style = "syntax #9ccfd8"; # foam for additions

        # Line numbers with Rose Pine colors
        line-numbers-minus-style = "#eb6f92"; # love
        line-numbers-plus-style = "#9ccfd8"; # foam
        line-numbers-zero-style = "#908caa"; # subtle

        # Commit decoration colors
        commit-decoration-style = "#f6c177 bold"; # gold
        file-decoration-style = "#c4a7e7"; # iris
        hunk-header-decoration-style = "#31748f"; # pine
      };
    };

    zsh.shellAliases = {
      g = "lazygit";
      gf = "onefetch --number-of-file-churns 0 --no-color-palette";
      ga = "git add";
      gaa = "git add --all";
      gs = "git status";
      gb = "git branch";
      gm = "git merge";
      gd = "git diff";
      gpl = "git pull";
      gplo = "git pull origin";
      gps = "git push";
      gpso = "git push origin";
      gpst = "git push --follow-tags";
      gcl = "git clone";
      gc = "git commit";
      gcm = "git commit -m";
      gcma = "git add --all && git commit -m";
      gtag = "git tag -ma";
      gch = "git checkout";
      gchb = "git checkout -b";
      glog = "git log --oneline --decorate --graph";
      glol = "git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset'";
      glola = "git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' --all";
      glols = "git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' --stat";
    };
  };

  home.packages = with pkgs; [
    gh
    git-secrets
    libsecret
  ]; # pkgs.git-lfs

  # Copy GitHub CLI config from backup directory during activation
  home.activation.copyGhConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    sourceDir="${customsecrets.ghConfigDir or ""}"
    if [[ -n "$sourceDir" && -d "$sourceDir" ]]; then
      $DRY_RUN_CMD mkdir -p $VERBOSE_ARG ~/.config/gh
      $DRY_RUN_CMD cp -r $VERBOSE_ARG "$sourceDir"/* ~/.config/gh/
      $DRY_RUN_CMD chmod $VERBOSE_ARG 600 ~/.config/gh/hosts.yml 2>/dev/null || true
    fi
  '';
}
