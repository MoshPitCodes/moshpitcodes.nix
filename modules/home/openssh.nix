{ pkgs, lib, username, customsecrets, ... }:
let
  # Get SSH key list from secrets or use defaults
  sshKeys = customsecrets.sshKeys.keys or [
    "id_ed25519"
    "id_rsa"
    "id_ecdsa"
  ];

  # Source directory for SSH keys (may not exist on all systems)
  sshSourceDir = customsecrets.sshKeys.sourceDir or "";

  # Generate full paths for identity files
  identityFiles = map (key: "/home/${username}/.ssh/${key}") sshKeys;
in
{
  # Activation script to copy SSH keys from source directory
  home.activation.copySSHKeys = lib.hm.dag.entryAfter ["writeBoundary"] ''
    SOURCE_DIR="${sshSourceDir}"
    DEST_DIR="$HOME/.ssh"

    # Only proceed if source directory exists and is specified
    if [ -n "$SOURCE_DIR" ] && [ -d "$SOURCE_DIR" ]; then
      $DRY_RUN_CMD mkdir -p "$DEST_DIR"
      $DRY_RUN_CMD chmod 700 "$DEST_DIR"

      echo "Copying SSH keys from $SOURCE_DIR to $DEST_DIR"

      # Copy each key file (private and public)
      ${lib.concatMapStringsSep "\n" (key: ''
        # Copy private key
        if [ -f "$SOURCE_DIR/${key}" ]; then
          $DRY_RUN_CMD cp -f "$SOURCE_DIR/${key}" "$DEST_DIR/${key}"
          $DRY_RUN_CMD chmod 600 "$DEST_DIR/${key}"
          echo "  Copied ${key} (private key)"
        fi

        # Copy public key
        if [ -f "$SOURCE_DIR/${key}.pub" ]; then
          $DRY_RUN_CMD cp -f "$SOURCE_DIR/${key}.pub" "$DEST_DIR/${key}.pub"
          $DRY_RUN_CMD chmod 644 "$DEST_DIR/${key}.pub"
          echo "  Copied ${key}.pub (public key)"
        fi
      '') sshKeys}

      # Copy SSH config if it exists
      if [ -f "$SOURCE_DIR/config" ]; then
        $DRY_RUN_CMD cp -f "$SOURCE_DIR/config" "$DEST_DIR/config"
        $DRY_RUN_CMD chmod 644 "$DEST_DIR/config"
        echo "  Copied SSH config file"
      fi

      # Copy known_hosts if it exists
      if [ -f "$SOURCE_DIR/known_hosts" ]; then
        $DRY_RUN_CMD cp -f "$SOURCE_DIR/known_hosts" "$DEST_DIR/known_hosts"
        $DRY_RUN_CMD chmod 644 "$DEST_DIR/known_hosts"
        echo "  Copied known_hosts file"
      fi

      echo "SSH keys copied successfully"
    else
      if [ -z "$SOURCE_DIR" ]; then
        echo "No SSH source directory configured in secrets.nix - skipping key copy"
      else
        echo "SSH source directory $SOURCE_DIR does not exist - skipping key copy"
      fi
    fi
  '';

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false; # Explicitly disable to avoid future warnings
    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = lib.head identityFiles; # Use first key as default
        addKeysToAgent = "yes";
      };
      "*" = {
        identityFile = identityFiles;
        addKeysToAgent = "yes";
        identitiesOnly = true;
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
        ${lib.concatMapStringsSep "\n" (key: ''
          keyfile="/home/${username}/.ssh/${key}"
          if [ -f "$keyfile" ]; then
            if ! ${pkgs.openssh}/bin/ssh-add -l 2>/dev/null | grep -q "$(${pkgs.openssh}/bin/ssh-keygen -lf "$keyfile" 2>/dev/null | awk '{print $2}')"; then
              ${pkgs.openssh}/bin/ssh-add "$keyfile" 2>/dev/null || true
            fi
          fi
        '') sshKeys}
      '';
    };
    Install.WantedBy = [ "default.target" ];
  };
}
