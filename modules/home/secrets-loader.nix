{
  lib,
  config,
  customsecrets,
  mpcConfig ? { },
  pkgs,
  ...
}:
let
  # Get external secrets path from mpcConfig (preferred) or fall back to customsecrets
  externalSecretsFile =
    if
      (mpcConfig ? external) && (mpcConfig.external ? envSecrets) && (mpcConfig.external.envSecrets != "")
    then
      mpcConfig.external.envSecrets
    else
      # Fallback to hardcoded path for backwards compatibility
      "/mnt/ugreen-nas/Coding/SecretsBackup2025/.secrets/env-secrets.sh";

  # Local cache location
  localSecretsFile = "${config.home.homeDirectory}/.secrets/env-secrets.sh";
in
{
  # Copy external secrets file to home directory during activation
  # This ensures secrets are available even if NAS is temporarily unavailable
  home.activation.copyExternalSecrets = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    echo "Checking for external secrets at: ${externalSecretsFile}"

    if [[ -f "${externalSecretsFile}" ]]; then
      $DRY_RUN_CMD mkdir -p $VERBOSE_ARG ~/.secrets
      $DRY_RUN_CMD chmod $VERBOSE_ARG 700 ~/.secrets
      $DRY_RUN_CMD cp $VERBOSE_ARG "${externalSecretsFile}" ~/.secrets/env-secrets.sh
      $DRY_RUN_CMD chmod $VERBOSE_ARG 600 ~/.secrets/env-secrets.sh
      echo "External secrets file copied from NAS"
    elif [[ -f "${localSecretsFile}" ]]; then
      echo "Using cached secrets file (NAS not accessible)"
    else
      echo "WARNING: No secrets file found at ${externalSecretsFile}"
      echo "API keys and tokens will not be available in shell sessions."
      echo "Create the file with:"
      echo "  export ANTHROPIC_API_KEY=\"sk-ant-...\""
      echo "  export OPENAI_API_KEY=\"sk-...\""
    fi
  '';

  # Source secrets in shell sessions with proper error handling
  programs.zsh.initExtra = ''
    # Load external secrets if available
    # These provide API keys (ANTHROPIC_API_KEY, OPENAI_API_KEY, etc.)
    if [[ -f ~/.secrets/env-secrets.sh ]]; then
      source ~/.secrets/env-secrets.sh
    fi
  '';

  programs.bash.initExtra = ''
    # Load external secrets if available
    # These provide API keys (ANTHROPIC_API_KEY, OPENAI_API_KEY, etc.)
    if [[ -f ~/.secrets/env-secrets.sh ]]; then
      source ~/.secrets/env-secrets.sh
    fi
  '';
}
