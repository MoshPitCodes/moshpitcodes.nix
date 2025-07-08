{ pkgs, username, ... }:
{
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    extraConfig = ''
      IdentitiesOnly yes
      AddKeysToAgent yes
    '';
    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "/home/${username}/.ssh/id_ed25519";
      };
      "*" = {
        identityFile = [
          "/home/${username}/.ssh/id_ed25519"
          "/home/${username}/.ssh/id_rsa"
          "/home/${username}/.ssh/id_ecdsa"
        ];
      };
    };
  };

  systemd.user.services.ssh-add-keys = {
    Unit = {
      Description = "Add SSH keys to agent";
      After = [ "graphical-session.target" ];
      Wants = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "ssh-add-keys" ''
        # Wait for SSH agent to be available
        timeout=30
        while [ $timeout -gt 0 ]; do
          if ${pkgs.openssh}/bin/ssh-add -l >/dev/null 2>&1; then
            break
          fi
          sleep 1
          timeout=$((timeout - 1))
        done
        
        # Add keys if they exist and aren't already loaded
        for key in id_ed25519 id_rsa id_ecdsa; do
          keyfile="/home/${username}/.ssh/$key"
          if [ -f "$keyfile" ]; then
            if ! ${pkgs.openssh}/bin/ssh-add -l 2>/dev/null | grep -q "$(${pkgs.openssh}/bin/ssh-keygen -lf "$keyfile" 2>/dev/null | awk '{print $2}')"; then
              ${pkgs.openssh}/bin/ssh-add "$keyfile" 2>/dev/null || true
            fi
          fi
        done
      '';
    };
    Install.WantedBy = [ "default.target" ];
  };
}
