{ pkgs, ... }:
{
  programs.git = {
    enable = true;

    userName = throw "<Enter user.name in ./modules/home/git.nix)>";
    userEmail = throw "<Enter user.email in ./modules/home/git.nix)>";

    extraConfig = {
      init.defaultBranch = "main";
      credential.helper = "store";
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
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
    includes = [
      # {
      #   contents = {
      #     user = {
      #       # Your work email
      #       email = "your-work-email@example.com";
      #     };

      #     core = {
      #       sshCommand = "ssh -i ~/.ssh/id_ed25519_work";
      #     };
      #   };
      #   condition = "hasconfig:remote.*.url:git@github.com:YOUR_ORGANIZATION/*";
      # }
    ];
  };

  home.packages = with pkgs; [
    gh
    git-secrets
  ]; # pkgs.git-lfs

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
