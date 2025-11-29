{ lib, username, customsecrets, ... }:
let
  # Get SSH key list from secrets or use defaults
  sshKeys = customsecrets.sshKeys.keys or [
    "id_ed25519"
    "id_rsa"
    "id_ecdsa"
  ];

  # Source directory for SSH keys (may not exist on all systems)

  # Generate full paths for identity files
  identityFiles = map (key: "/home/${username}/.ssh/${key}") sshKeys;
in
{
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
