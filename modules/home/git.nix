{
  lib,
  pkgs,
  customsecrets,
  mpcConfig ? { },
  ...
}:
let
  # Get git config from mpcConfig (preferred) or customsecrets
  gitConfig = mpcConfig.git or customsecrets.git or { };

  # Signing key can be in git.signingkey (new) or git.user.signingkey (legacy)
  signingKey = gitConfig.signingkey or gitConfig.user.signingkey or "";
in
{
  programs = {
    git = {
      enable = true;

      settings = {
        user = {
          name = gitConfig.userName or "User";
          email = gitConfig.userEmail or "user@example.com";
          signingkey = signingKey;
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
    # Get ghConfigDir from mpcConfig (preferred) or customsecrets
    sourceDir="${mpcConfig.external.ghConfigDir or customsecrets.ghConfigDir or ""}"
    if [[ -n "$sourceDir" && -d "$sourceDir" ]]; then
      echo "Copying GitHub CLI config from: $sourceDir"
      $DRY_RUN_CMD mkdir -p $VERBOSE_ARG ~/.config/gh
      $DRY_RUN_CMD cp -r $VERBOSE_ARG "$sourceDir"/* ~/.config/gh/
      $DRY_RUN_CMD chmod $VERBOSE_ARG 600 ~/.config/gh/hosts.yml 2>/dev/null || true
      echo "GitHub CLI config copied successfully"
    elif [[ -n "$sourceDir" ]]; then
      echo "WARNING: GitHub CLI config not found at: $sourceDir"
    fi
  '';
}
