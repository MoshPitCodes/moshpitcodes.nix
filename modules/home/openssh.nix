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
  # Note: Disabled due to bash string interpolation issues with Nix concatMapStringsSep
  # SSH keys should be manually copied to ~/.ssh/ before running home-manager
  # Or use a simple script like: cp -r /path/to/ssh/keys/* ~/.ssh/ && chmod 600 ~/.ssh/id_*

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

  # Systemd service to auto-add SSH keys
  # Note: Disabled due to bash string interpolation issues
  # Keys will be added automatically via AddKeysToAgent in SSH config
  # Or via the zsh init script in zsh.nix
}
