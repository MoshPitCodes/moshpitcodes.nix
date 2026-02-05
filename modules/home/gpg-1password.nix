{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.programs.gpg.onepassword;

  # Custom pinentry that retrieves GPG passphrase from 1Password
  pinentry-1password = pkgs.writeShellScript "pinentry-1password" ''
    #!/usr/bin/env bash
    # Custom pinentry script that retrieves GPG passphrase from 1Password
    # This script follows the Assuan protocol used by GnuPG

    # 1Password item details - customize these via environment variables
    OP_VAULT="''${OP_GPG_VAULT:-${cfg.vault}}"
    OP_ITEM="''${OP_GPG_ITEM:-${cfg.itemName}}"
    OP_FIELD="''${OP_GPG_FIELD:-${cfg.fieldName}}"

    # Function to get passphrase from 1Password
    get_passphrase() {
        # Check if op CLI is available
        if ! command -v op &> /dev/null; then
            echo "ERR 67108949 op CLI not found <Pinentry>" >&2
            return 1
        fi

        # Try to get the passphrase from 1Password
        local passphrase
        passphrase=$(op item get "$OP_ITEM" --vault "$OP_VAULT" --fields "$OP_FIELD" 2>/dev/null)
        
        if [ $? -ne 0 ] || [ -z "$passphrase" ]; then
            echo "ERR 67108924 1Password retrieval failed <Pinentry>" >&2
            return 1
        fi
        
        echo "$passphrase"
        return 0
    }

    # Main Assuan protocol loop
    echo "OK Pinentry-1Password ready"

    while IFS= read -r line; do
        case "$line" in
            GETPIN)
                passphrase=$(get_passphrase)
                if [ $? -eq 0 ]; then
                    echo "D $passphrase"
                    echo "OK"
                else
                    echo "ERR 83886179 Operation cancelled <Pinentry>"
                fi
                ;;
            SETDESC*)
                echo "OK"
                ;;
            SETPROMPT*)
                echo "OK"
                ;;
            SETERROR*)
                echo "OK"
                ;;
            SETTITLE*)
                echo "OK"
                ;;
            SETOK*)
                echo "OK"
                ;;
            SETCANCEL*)
                echo "OK"
                ;;
            SETNOTOK*)
                echo "OK"
                ;;
            SETQUALITYBAR*)
                echo "OK"
                ;;
            GETINFO*)
                echo "D pinentry-1password"
                echo "OK"
                ;;
            OPTION*)
                echo "OK"
                ;;
            BYE)
                echo "OK closing connection"
                exit 0
                ;;
            *)
                echo "OK"
                ;;
        esac
    done
  '';
in
{
  options.programs.gpg.onepassword = {
    enable = lib.mkEnableOption "1Password integration for GPG passphrase";

    vault = lib.mkOption {
      type = lib.types.str;
      default = "Private";
      description = "1Password vault name";
    };

    itemName = lib.mkOption {
      type = lib.types.str;
      default = "Github MoshPitCodes GPG Signing Key 2025-12-03";
      description = "1Password item name containing GPG passphrase";
    };

    fieldName = lib.mkOption {
      type = lib.types.str;
      default = "passphrase";
      description = "Field name in 1Password item containing the passphrase";
    };
  };

  config = lib.mkIf cfg.enable {
    # Override pinentry to use 1Password
    services.gpg-agent.pinentryPackage = lib.mkForce pinentry-1password;

    # Add environment variables for zsh
    programs.zsh.sessionVariables = {
      OP_GPG_VAULT = cfg.vault;
      OP_GPG_ITEM = cfg.itemName;
      OP_GPG_FIELD = cfg.fieldName;
    };
  };
}
