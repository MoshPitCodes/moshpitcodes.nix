{ lib, username, customsecrets, ... }:
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
  # Copy SSH keys from source directory during activation
  home.activation.copySSHKeys = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    sourceDir="${sshSourceDir}"
    if [[ -n "$sourceDir" && -d "$sourceDir" ]]; then
      $DRY_RUN_CMD mkdir -p $VERBOSE_ARG ~/.ssh
      $DRY_RUN_CMD chmod $VERBOSE_ARG 700 ~/.ssh
      ${lib.concatMapStringsSep "\n" (key: ''
        if [[ -f "$sourceDir/${key}" ]]; then
          $DRY_RUN_CMD cp $VERBOSE_ARG "$sourceDir/${key}" ~/.ssh/${key}
          $DRY_RUN_CMD chmod $VERBOSE_ARG 600 ~/.ssh/${key}
        fi
        if [[ -f "$sourceDir/${key}.pub" ]]; then
          $DRY_RUN_CMD cp $VERBOSE_ARG "$sourceDir/${key}.pub" ~/.ssh/${key}.pub
          $DRY_RUN_CMD chmod $VERBOSE_ARG 644 ~/.ssh/${key}.pub
        fi
      '') sshKeys}
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
        extraOptions = {
          AddKeysToAgent = "yes";
        };
      };
      "*" = {
        identityFile = identityFiles;
        identitiesOnly = true;
        extraOptions = {
          AddKeysToAgent = "yes";
        };
      };
    };
  };
}
