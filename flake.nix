{
  description = "NixOS Configuration for Desktops, Laptops, and VMs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
    hypr-contrib.url = "github:hyprwm/contrib";
    hyprpicker.url = "github:hyprwm/hyprpicker";
    alejandra.url = "github:kamadorueda/alejandra/3.0.0";
    nix-gaming.url = "github:fufexan/nix-gaming";
    hyprland.url = "github:hyprwm/Hyprland";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix = {
      url = "github:gerg-l/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    yazi-plugins = {
      url = "github:yazi-rs/plugins";
      flake = false;
    };
    ghostty = {
      url = "github:ghostty-org/ghostty";
    };
    zig.url = "github:mitchellh/zig-overlay";
    nvf.url = "github:notashelf/nvf";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    s4rchiso-plymouth = {
      url = "github:SergioRibera/s4rchiso-plymouth-theme";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, self, ... }@inputs:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;

      # Import custom overlays for package version overrides
      overlays = import ./overlays { inherit inputs; };

      pkgs = import nixpkgs {
        inherit system;
        overlays = overlays ++ [ inputs.s4rchiso-plymouth.overlays.default ];
        config.allowUnfree = true;
      };

      # ====================
      # Configuration Loading Strategy
      # ====================
      # Priority order:
      #   1. config.nix (pure, committable) - PREFERRED
      #   2. secrets.nix (impure, git-ignored) - BACKWARDS COMPATIBILITY
      #   3. defaultConfig - CI/TESTING ONLY
      #
      # Secret values (hashedPassword, API keys) are loaded at RUNTIME
      # from external files specified in config.nix, NOT at evaluation time.
      # This allows pure evaluation without --impure flag for most operations.

      # Default configuration for CI/testing environments
      # WARNING: These values are INSECURE and must never be used in production
      defaultConfig = {
        username = "testuser";
        reponame = "moshpitcodes.nix";
        git = {
          userName = "CI Test User";
          userEmail = "ci@example.com";
          signingkey = "";
        };
        network = {
          wifiSSID = "";
        };
        samba = {
          username = "guest";
          domain = "WORKGROUP";
        };
        apiKeys = {
          anthropic = "";
          openai = "";
        };
        external = {
          secretsDir = "";
          userPasswordFile = "";
          sambaCredentials = "";
          envSecrets = "";
          sshKeysDir = "";
          sshKeys = [ ];
          gpgDir = "";
          ghConfigDir = "";
        };
        # CI-only password hash - NEVER use in production
        _ciHashedPassword = "$6$rounds=10000$CI.INSECURE$NEVER.USE.IN.PRODUCTION.SYSTEMS";
      };

      # Load config.nix (pure, preferred)
      # Falls back to secrets.nix for backwards compatibility
      loadConfiguration =
        let
          configPath = ./config.nix;
          secretsPath = ./secrets.nix;
        in
        if builtins.pathExists configPath then
          let
            config = import configPath;
          in
          # Merge with defaults to ensure all keys exist
          lib.recursiveUpdate defaultConfig config
        else if builtins.pathExists secretsPath then
          # Backwards compatibility: load secrets.nix
          # This requires the file to be present (not git-ignored during evaluation)
          let
            secrets = import secretsPath;
          in
          lib.recursiveUpdate defaultConfig secrets
        else
          # CI/testing: use defaults
          defaultConfig;

      # The loaded configuration (paths only, no secret values)
      mpcConfig = loadConfiguration;

      # Extract username for convenience
      inherit (mpcConfig) username;

      # Build customsecrets for backwards compatibility with existing modules
      # This structure matches what modules expect, but secret VALUES
      # are loaded at runtime from external files, not embedded here
      customsecrets = mpcConfig // {
        # For user.nix: hashedPassword is read from external file at runtime
        # We set a placeholder that's replaced by activation script
        # If external.userPasswordFile is set, the actual hash is loaded at boot
        hashedPassword =
          if mpcConfig.external.userPasswordFile != "" then
            # This is a marker - actual password is loaded from file by users.users.<name>.hashedPasswordFile
            # We use initialHashedPassword as fallback for first boot
            mpcConfig._ciHashedPassword or defaultConfig._ciHashedPassword
          else if mpcConfig ? hashedPassword then
            # Backwards compatibility: direct hash in config (not recommended)
            mpcConfig.hashedPassword
          else
            defaultConfig._ciHashedPassword;

        # SSH keys configuration for backwards compatibility
        sshKeys = {
          sourceDir = mpcConfig.external.sshKeysDir or "";
          keys = mpcConfig.external.sshKeys or [ ];
        };

        # GPG directory for backwards compatibility
        gpgDir = mpcConfig.external.gpgDir or "";

        # GitHub CLI config for backwards compatibility
        ghConfigDir = mpcConfig.external.ghConfigDir or "";

        # Samba configuration with credentials file
        samba = (mpcConfig.samba or { }) // {
          credentialsFile = mpcConfig.external.sambaCredentials or "";
          password = ""; # Never stored, loaded from credentialsFile
        };
      };

      # Helper to create a NixOS system configuration
      mkSystem =
        {
          host,
          hostPath,
          extraOverlays ? [ ],
        }:
        nixpkgs.lib.nixosSystem {
          modules = [
            { nixpkgs.hostPlatform = system; }
            hostPath
            ./modules/core/mpc-secrets.nix
            { nixpkgs.overlays = overlays ++ extraOverlays; }
            # Enable MPC secrets module with config from config.nix
            {
              mpc.secrets = lib.mkIf (mpcConfig.external.secretsDir != "") {
                enable = true;
                basePath = mpcConfig.external.secretsDir;
                userPasswordFile =
                  let
                    fullPath = mpcConfig.external.userPasswordFile;
                  in
                  if fullPath != "" && lib.hasPrefix mpcConfig.external.secretsDir fullPath then
                    lib.removePrefix "${mpcConfig.external.secretsDir}/" fullPath
                  else
                    null;
                sambaCredentialsFile =
                  let
                    fullPath = mpcConfig.external.sambaCredentials;
                  in
                  if fullPath != "" && lib.hasPrefix mpcConfig.external.secretsDir fullPath then
                    lib.removePrefix "${mpcConfig.external.secretsDir}/" fullPath
                  else
                    null;
                envSecretsFile =
                  let
                    fullPath = mpcConfig.external.envSecrets;
                  in
                  if fullPath != "" && lib.hasPrefix mpcConfig.external.secretsDir fullPath then
                    lib.removePrefix "${mpcConfig.external.secretsDir}/" fullPath
                  else
                    null;
                sshKeysDir = mpcConfig.external.sshKeysDir;
                sshKeys = mpcConfig.external.sshKeys;
                gpgDir = mpcConfig.external.gpgDir;
                ghConfigDir = mpcConfig.external.ghConfigDir;
              };
            }
          ];
          specialArgs = {
            inherit
              self
              inputs
              username
              customsecrets
              host
              ;
            mpcConfig = mpcConfig;
          };
        };

    in
    {
      nixosConfigurations = {
        desktop = mkSystem {
          host = "desktop";
          hostPath = ./hosts/desktop;
          extraOverlays = [ inputs.s4rchiso-plymouth.overlays.default ];
        };

        laptop = mkSystem {
          host = "laptop";
          hostPath = ./hosts/laptop;
          extraOverlays = [ inputs.s4rchiso-plymouth.overlays.default ];
        };

        vm = mkSystem {
          host = "vm";
          hostPath = ./hosts/vm;
        };

        vmware-guest = mkSystem {
          host = "nixos-vmware";
          hostPath = ./hosts/vmware-guest;
        };

        wsl = mkSystem {
          host = "nixos-wsl";
          hostPath = ./hosts/wsl;
        };
      };

      packages.${system}.wsl-distro = self.nixosConfigurations.wsl.config.system.build.tarballBuilder;

      devShells.${system} = {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [
            treefmt
            nixfmt
            shfmt
            deadnix
            statix
          ];
          shellHook = ''
            echo "🚀 NixOS Development Environment"
            echo "Available commands:"
            echo "  treefmt        - Format all files"
            echo "  treefmt --fail-on-change - Check if files are formatted"
            echo "  nixfmt - Format Nix files"
            echo "  shfmt          - Format shell scripts"
            echo "  deadnix        - Find dead Nix code"
            echo "  statix         - Lint Nix files"
          '';
        };

        claude-flow = import ./shells/claude-flow.nix { inherit pkgs; };
        devshell = import ./shells/devshell.nix { inherit pkgs; };
      };
    };
}
