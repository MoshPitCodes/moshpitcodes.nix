{
  lib,
  username,
  customsecrets,
  ...
}:
let
  # Get SSH key list from secrets or use defaults
  sshKeys =
    customsecrets.sshKeys.keys or [
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

  # Pre-seed GitHub's SSH host keys so connections never prompt for verification.
  # Without this, ssh_askpass failures cause "Host key verification failed"
  # errors (especially in non-interactive contexts like git push).
  # Keys sourced from: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints
  home.file.".ssh/known_hosts".text = builtins.concatStringsSep "\n" [
    "github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl"
    "github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg="
    "github.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk="
    ""
  ];

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
