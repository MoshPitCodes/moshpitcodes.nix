{
  description = "ShiftTab NixOS Configuration";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://hyprland.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix = {
      url = "github:gerg-l/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak";

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake/0fa995bec0e391b45b032fbd9d6e03609a30c115";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    yazi-plugins = {
      url = "github:yazi-rs/plugins";
      flake = false;
    };

    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sidecar = {
      url = "github:marcus/sidecar/v0.74.0";
      flake = false;
    };

    td = {
      url = "github:marcus/td/v0.37.0";
      flake = false;
    };

    reposync = {
      url = "github:MoshPitCodes/reposync";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forEachSystem = nixpkgs.lib.genAttrs supportedSystems;

      validateSecrets =
        secrets:
        assert builtins.isAttrs secrets || throw "secrets.nix must return an attribute set";
        assert (secrets.username or null) != null || throw "secrets.nix must define 'username'";
        secrets;

      # Load secrets from either the original working tree path (impure) or
      # from flake source path (pure). This keeps git-ignored secrets.nix usable
      # with commands like `nixos-rebuild --flake .#host --impure`.
      flakeRoot = builtins.getEnv "FLAKE_ROOT";
      pwdPath = builtins.getEnv "PWD";
      secretsPath =
        let
          basePath = if flakeRoot != "" then flakeRoot else pwdPath;
        in
        if basePath != "" then /. + basePath + "/secrets.nix" else null;

      customsecrets =
        if secretsPath != null && builtins.pathExists secretsPath then
          validateSecrets (import secretsPath)
        else if builtins.pathExists ./secrets.nix then
          validateSecrets (import ./secrets.nix)
        else
          builtins.trace "WARNING: secrets.nix not found. Using default fallback values." {
            username = "user";
            hashedPassword = "";
            reponame = "dotfiles";
            git = {
              userName = "User";
              userEmail = "user@example.com";
              user.signingkey = "";
            };
            network = {
              wifiSSID = "";
              wifiPassword = "";
            };
            apiKeys = {
              anthropic = "";
              openai = "";
            };
            backup = {
              nasBackupPath = "";
            };
          };
      # Import overlays
      overlays = import ./overlays { inherit inputs; };
    in
    {
      nixosConfigurations = {
        laptop =
          let
            host = "laptop";
          in
          nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = {
              inherit
                self
                inputs
                host
                customsecrets
                ;
              username = customsecrets.username;
            };
            modules = [
              ./hosts/${host}
              home-manager.nixosModules.home-manager
              {
                nixpkgs.config.allowUnfree = true;
                nixpkgs.overlays = overlays;
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  extraSpecialArgs = {
                    inherit
                      self
                      inputs
                      host
                      customsecrets
                      ;
                    username = customsecrets.username;
                  };
                  users.${customsecrets.username} = import ./modules/home/default.laptop.nix;
                };
              }
            ];
          };

        desktop =
          let
            host = "desktop";
          in
          nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = {
              inherit
                self
                inputs
                host
                customsecrets
                ;
              username = customsecrets.username;
            };
            modules = [
              ./hosts/${host}
              home-manager.nixosModules.home-manager
              {
                nixpkgs.config.allowUnfree = true;
                nixpkgs.overlays = overlays;
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  extraSpecialArgs = {
                    inherit
                      self
                      inputs
                      host
                      customsecrets
                      ;
                    username = customsecrets.username;
                  };
                  users.${customsecrets.username} = import ./modules/home/default.desktop.nix;
                };
              }
            ];
          };

        vmware-guest =
          let
            host = "vmware-guest";
          in
          nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = {
              inherit
                self
                inputs
                host
                customsecrets
                ;
              username = customsecrets.username;
            };
            modules = [
              ./hosts/${host}
              home-manager.nixosModules.home-manager
              {
                nixpkgs.config.allowUnfree = true;
                nixpkgs.overlays = overlays;
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  extraSpecialArgs = {
                    inherit
                      self
                      inputs
                      host
                      customsecrets
                      ;
                    username = customsecrets.username;
                  };
                  users.${customsecrets.username} = import ./modules/home/default.vmware-guest.nix;
                };
              }
            ];
          };
      };

      devShells = forEachSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            name = "dev-environment";
            packages = with pkgs; [
              git
              nixfmt
              nil
              treefmt
            ];
            shellHook = ''
              echo "Development environment loaded."
            '';
          };
        }
      );

      formatter = forEachSystem (system: nixpkgs.legacyPackages.${system}.nixfmt);
    };
}
