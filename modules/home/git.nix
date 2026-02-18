# Git configuration
{
  pkgs,
  lib,
  customsecrets,
  ...
}:
{
  programs = {
    git = {
      enable = true;

      settings = {
        user = {
          name = customsecrets.git.userName or "User";
          email = customsecrets.git.userEmail or "user@example.com";
          signingkey = customsecrets.git.user.signingkey or "";
        };

        init.defaultBranch = "main";
        pull.rebase = true;
        push.autoSetupRemote = true;
        core.editor = "vim";
        core.autocrlf = "input";
        credential.helper = "${pkgs.git}/lib/git-core/git-credential-libsecret";
        merge.conflictstyle = "diff3";
        diff.colorMoved = "default";
        commit.gpgsign = true;
        gpg.format = "openpgp";

        # Aliases
        alias = {
          st = "status";
          co = "checkout";
          br = "branch";
          ci = "commit";
          lg = "log --oneline --graph --decorate";
        };
      };
    };

    # Delta for git diffs
    delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        navigate = true;
        light = false;
        side-by-side = true;
        line-numbers = true;
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
      gh-backup = "test -d ${customsecrets.ghConfigDir or ""} && mkdir -p ${
        customsecrets.ghConfigDir or ""
      } && cp -f ~/.config/gh/hosts.yml ${
        customsecrets.ghConfigDir or ""
      }/hosts.yml && echo 'gh config backed up' || echo 'Backup directory not configured'";
    };
  };

  home.packages = with pkgs; [
    gh
    git-secrets
    libsecret
  ];

  # Restore gh CLI configuration from backup
  # NOTE: gh CLI uses SSH for git operations. If not authenticated, run:
  #   gh auth login --hostname github.com --git-protocol ssh --web
  home.activation.ghAuth =
    let
      ghConfigDir = customsecrets.ghConfigDir or "";
    in
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      # Try to restore from backup if it exists
      if [[ -n "${ghConfigDir}" && -d "${ghConfigDir}" ]]; then
        $DRY_RUN_CMD mkdir -p $VERBOSE_ARG ~/.config/gh
        if [[ -f "${ghConfigDir}/hosts.yml" ]]; then
          $DRY_RUN_CMD cp $VERBOSE_ARG -f "${ghConfigDir}/hosts.yml" ~/.config/gh/hosts.yml
          $DRY_RUN_CMD chmod $VERBOSE_ARG 600 ~/.config/gh/hosts.yml
          echo "Restored gh CLI authentication from backup"
        fi
      fi

      # Check if gh is authenticated, provide helpful message if not
      if ! ${pkgs.gh}/bin/gh auth status >/dev/null 2>&1; then
        echo "gh CLI not authenticated. Run: gh auth login --hostname github.com --git-protocol ssh --web"
      fi
    '';
}
