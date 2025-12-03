{ lib, pkgs, customsecrets, ... }:
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
        alias = {
          lg = "log --oneline --decorate --graph";
          lol = "log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset'";
          lola = "log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' --all";
          lols = "log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' --stat";
        };
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
    gnupg
    pinentry-gnome3
  ]; # pkgs.git-lfs

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-gnome3;
    enableSshSupport = false; # Use GNOME keyring for SSH
    defaultCacheTtl = 1800;
    maxCacheTtl = 7200;
  };

  # Copy GitHub CLI config from backup directory during activation
  home.activation.copyGhConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    sourceDir="${customsecrets.ghConfigDir or ""}"
    if [[ -n "$sourceDir" && -d "$sourceDir" ]]; then
      $DRY_RUN_CMD mkdir -p $VERBOSE_ARG ~/.config/gh
      $DRY_RUN_CMD cp -r $VERBOSE_ARG "$sourceDir"/* ~/.config/gh/
      $DRY_RUN_CMD chmod $VERBOSE_ARG 600 ~/.config/gh/hosts.yml 2>/dev/null || true
    fi
  '';

  # Copy GPG keyring from backup directory during activation
  home.activation.copyGpgKeys = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    sourceDir="${customsecrets.gpgDir or ""}"
    if [[ -n "$sourceDir" && -d "$sourceDir" ]]; then
      $DRY_RUN_CMD mkdir -p $VERBOSE_ARG ~/.gnupg
      $DRY_RUN_CMD chmod $VERBOSE_ARG 700 ~/.gnupg
      $DRY_RUN_CMD cp -r $VERBOSE_ARG "$sourceDir"/* ~/.gnupg/
      $DRY_RUN_CMD chmod $VERBOSE_ARG 600 ~/.gnupg/private-keys-v1.d/* 2>/dev/null || true
      $DRY_RUN_CMD chmod $VERBOSE_ARG 600 ~/.gnupg/trustdb.gpg 2>/dev/null || true
    fi
  '';
}
