{ pkgs, customsecrets, ... }:
{
  programs.git = {
    enable = true;

    userName = customsecrets.git.userName;
    userEmail = customsecrets.git.userEmail;

    extraConfig = {
      init.defaultBranch = "main";
      credential.helper = "${pkgs.git}/lib/git-core/git-credential-libsecret";
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
      commit.gpgsign = true;
      user.signingkey = customsecrets.git.user.signingkey;
      gpg.format = "openpgp";
    };

    delta = {
      enable = true;
      options = {
        line-numbers = true;
        side-by-side = true;
        diff-so-fancy = true;
        navigate = true;
      };
    };
    includes = [];
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

  programs.zsh.shellAliases = {
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
}
