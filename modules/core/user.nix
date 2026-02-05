{
  config,
  lib,
  pkgs,
  inputs,
  username,
  host,
  customsecrets,
  mpcConfig ? { },
  ...
}:
let
  # Determine if we should use external password file
  useExternalPassword =
    (mpcConfig ? external)
    && (mpcConfig.external ? userPasswordFile)
    && (mpcConfig.external.userPasswordFile != "");

  externalPasswordFile = mpcConfig.external.userPasswordFile or "";
in
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    extraSpecialArgs = {
      inherit
        inputs
        username
        host
        customsecrets
        mpcConfig
        ;
    };
    users.${username} = {
      imports =
        if (host == "desktop") then
          [ ./../home/default.desktop.nix ]
        else if (host == "vm" || host == "nixos-vmware") then
          [ ./../home/default.vm.nix ]
        else if (host == "nixos-wsl") then
          [ ./../home/default.wsl.nix ]
        else
          [ ./../home ];
      home = {
        username = "${username}";
        homeDirectory = "/home/${username}";
        stateVersion = "25.05";
      };
      programs.home-manager.enable = true;
    };
    backupFileExtension = "hm-backup";
  };

  # User configuration with external password file support
  users.users.${username} = {
    isNormalUser = true;
    description = "${username}";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    shell = pkgs.zsh;
  }
  // (
    # Password configuration strategy:
    # 1. If external password file is configured -> use hashedPasswordFile (NixOS 23.11+)
    # 2. Otherwise -> fall back to hashedPassword from customsecrets
    if useExternalPassword then
      {
        # hashedPasswordFile reads the hash from file at boot time
        # This is the recommended approach for external secrets
        hashedPasswordFile = externalPasswordFile;
      }
    else
      {
        # Backwards compatibility: use hash directly from config
        inherit (customsecrets) hashedPassword;
      }
  );

  # Activation script to validate password file exists (if configured)
  system.activationScripts.validateUserPassword = lib.mkIf useExternalPassword {
    deps = [ "specialfs" ];
    text = ''
      if [[ ! -f "${externalPasswordFile}" ]]; then
        echo "WARNING: User password file not found: ${externalPasswordFile}"
        echo "The user '${username}' may not be able to log in."
        echo "Create it with: mkpasswd -m sha-512 > ${externalPasswordFile}"
      else
        echo "User password file found: ${externalPasswordFile}"
      fi
    '';
  };

  nix.settings.allowed-users = [ "${username}" ];
}
