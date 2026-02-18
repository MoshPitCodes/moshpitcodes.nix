# SSH client configuration with key management
{
  lib,
  customsecrets,
  ...
}:
let
  sshKeys =
    customsecrets.sshKeys.keys or [
      "id_ed25519"
      "id_rsa"
      "id_ecdsa"
    ];
  firstKey = builtins.head sshKeys;
in
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/${firstKey}";
        identitiesOnly = true;
      };
      "*" = {
        extraOptions = {
          AddKeysToAgent = "yes";
        };
        userKnownHostsFile = "~/.ssh/known_hosts";
      };
    };
  };

  # Pre-seed GitHub SSH host keys to prevent interactive prompts
  home.file.".ssh/known_hosts" = {
    force = true;
    text = ''
      github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
      github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=
      github.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZKyMdRaahYm5axPQ5BO5h9X7yWkgyJr+v4SFZMjRKXvEqP+7N7Ax7B4VyjWK3WMmoMV3qSNKQ+PjDOH0REzAlhnFBG4SmJYee5JGhJFi9E0e0re1jTj3M/OOqJPToa5JNAV2ENfkTDAKNOOaCRCN+/r0FKXhJWkSMTpSmKIIqmOE9GFBJ+mzOBtuCZ+Rwi5mDHEE9BKYWP7OYvl7qdPkzQBhvTr29Kx7a10gOCFBjLhByXg2PsXoLgI4Y5GI/V5kKReYiY5UH0TwcOY1C3YhL0klj3kJMN3ILf+w0+DU1zBf4C7fMgEIoLKbECC8II7cW9c+G1P0Am5m4OA+1Y9pEDl6zCFGBiLp0V3FPHIZ0R18cTGUu0IXP/2WQ71YxBOla1lEQVP1Mp2xJ27sLkJRiZ1kOP3UhTnMdCYvLKqluNZ+2E7Tq6YZSACwE=
    '';
  };

  # Copy SSH keys from source directory during activation
  home.activation.copySSHKeys =
    lib.mkIf (customsecrets ? sshKeys && customsecrets.sshKeys ? sourceDir)
      (
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          if [ -d "${customsecrets.sshKeys.sourceDir}" ]; then
            install -d -m 0700 "$HOME/.ssh"
            for key in ${builtins.concatStringsSep " " sshKeys}; do
              if [ -f "${customsecrets.sshKeys.sourceDir}/$key" ]; then
                install -m 0600 "${customsecrets.sshKeys.sourceDir}/$key" "$HOME/.ssh/$key"
              fi
              if [ -f "${customsecrets.sshKeys.sourceDir}/$key.pub" ]; then
                install -m 0644 "${customsecrets.sshKeys.sourceDir}/$key.pub" "$HOME/.ssh/$key.pub"
              fi
            done
          fi
        ''
      );
}
