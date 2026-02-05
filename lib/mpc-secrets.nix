# NixOS Secrets Management Library
# Provides pure functions for external secret file references
# Secrets are NEVER read at evaluation time - only paths are configured
#
# This module follows NixOS best practices:
# - Pure evaluation (no builtins.readFile for secrets)
# - Secrets read at runtime via activation scripts or systemd services
# - File paths configured declaratively, contents loaded imperatively

{ lib }:

let
  # Type definitions for secret file references
  # These store paths only, not contents
  secretFileType = lib.types.submodule {
    options = {
      path = lib.mkOption {
        type = lib.types.str;
        description = "Path to the secret file (read at runtime, not evaluation)";
        example = "/mnt/nas/.secrets/api-key";
      };
      mode = lib.mkOption {
        type = lib.types.str;
        default = "0600";
        description = "File permissions when copied to local system";
      };
      owner = lib.mkOption {
        type = lib.types.str;
        default = "root";
        description = "Owner of the local copy";
      };
      group = lib.mkOption {
        type = lib.types.str;
        default = "root";
        description = "Group of the local copy";
      };
    };
  };

  # Create a secret file reference (path only, no content)
  mkSecretFile =
    {
      path,
      mode ? "0600",
      owner ? "root",
      group ? "root",
    }:
    {
      inherit
        path
        mode
        owner
        group
        ;
    };

  # Create a secret environment variable reference
  # The value is loaded from file at shell initialization
  mkSecretEnv =
    {
      name,
      file,
      fallback ? "",
    }:
    {
      inherit name file fallback;
    };

  # Generate shell script snippet to load a secret file into an env var
  loadSecretEnvScript = secretEnv: ''
    if [[ -f "${secretEnv.file}" ]]; then
      export ${secretEnv.name}="$(cat "${secretEnv.file}" | tr -d '\n')"
    elif [[ -n "${secretEnv.fallback}" ]]; then
      export ${secretEnv.name}="${secretEnv.fallback}"
    fi
  '';

  # Generate activation script to copy secret from external source
  # Used for secrets that must be local (e.g., samba credentials)
  mkCopySecretActivation =
    {
      name,
      source,
      dest,
      mode ? "0600",
      owner ? "root",
      group ? "root",
      createDir ? true,
    }:
    ''
      # Copy secret: ${name}
      ${lib.optionalString createDir ''
        mkdir -p "$(dirname "${dest}")"
        chmod 700 "$(dirname "${dest}")"
      ''}
      if [[ -f "${source}" ]]; then
        cp "${source}" "${dest}"
        chmod ${mode} "${dest}"
        chown ${owner}:${group} "${dest}"
        echo "Secret '${name}' copied from external source"
      else
        echo "WARNING: Secret source not found: ${source}"
      fi
    '';

  # Validate that a secret file exists (for use in assertions)
  # This check happens at build time for paths that MUST exist
  assertSecretExists = path: message: lib.asserts.assertMsg (builtins.pathExists path) message;

in
{
  inherit
    secretFileType
    mkSecretFile
    mkSecretEnv
    loadSecretEnvScript
    mkCopySecretActivation
    assertSecretExists
    ;

  # Convenience function to check if running in CI (no secrets available)
  isCI = builtins.getEnv "CI" != "" || builtins.getEnv "GITHUB_ACTIONS" != "";

  # Default values for CI/testing environments
  ciDefaults = {
    username = "testuser";
    hashedPassword = "$6$rounds=10000$INSECURE.CI.ONLY$DO.NOT.USE.IN.PRODUCTION.EVER";
    git = {
      userName = "CI User";
      userEmail = "ci@example.com";
      signingkey = "";
    };
  };
}
