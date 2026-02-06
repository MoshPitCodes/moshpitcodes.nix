{
  pkgs,
  inputs,
  username,
  host,
  customsecrets,
  ...
}:
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
        ;
    };
    users.${username} = {
      imports =
        if (host == "desktop") then
          [ ./../home ]
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

  users.users.${username} = {
    inherit (customsecrets) hashedPassword;
    isNormalUser = true;
    description = "${username}";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    shell = pkgs.zsh;
  };
  nix.settings.allowed-users = [ "${username}" ];
}
