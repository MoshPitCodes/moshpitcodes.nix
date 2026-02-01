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

      # Import custom overlays for package version overrides
      overlays = import ./overlays { inherit inputs; };

      pkgs = import nixpkgs {
        inherit system;
        overlays = overlays ++ [ inputs.s4rchiso-plymouth.overlays.default ];
        config.allowUnfree = true;
      };

      # Load secrets with fallback defaults for CI/testing environments
      defaultSecrets = {
        username = "testuser";
        # INSECURE: CI/test-only hash - DO NOT use in production
        # Generate a real hash with: mkpasswd -m sha-512
        hashedPassword = "$6$INSECURE.CI.TEST$DONOTUSE.THIS.IN.PRODUCTION";
        reponame = "moshpitcodes.nix";
        git = {
          userName = "Test User";
          userEmail = "test@example.com";
          user.signingkey = "testkey";
        };
        network = {
          wifiSSID = "";
          wifiPassword = "";
        };
        apiKeys = {
          anthropic = "";
          openai = "";
        };
        sshKeys = {
          sourceDir = "";
          keys = [
            "id_ed25519"
            "id_rsa"
            "id_ecdsa"
          ];
        };
      };

      # Validate that secrets have all required keys (including nested structures)
      validateSecrets =
        secrets:
        let
          requiredKeys = [
            "username"
            "hashedPassword"
            "git"
            "network"
          ];
          missingKeys = builtins.filter (k: !(builtins.hasAttr k secrets)) requiredKeys;
          # Validate nested git keys
          requiredGitKeys = [
            "userName"
            "userEmail"
          ];
          missingGitKeys =
            if builtins.hasAttr "git" secrets then
              builtins.filter (k: !(builtins.hasAttr k secrets.git)) requiredGitKeys
            else
              requiredGitKeys;
        in
        if missingKeys != [ ] then
          throw "secrets.nix missing required keys: ${builtins.toString missingKeys}"
        else if missingGitKeys != [ ] then
          throw "secrets.nix git section missing required keys: ${builtins.toString missingGitKeys}"
        else
          secrets;

      # Load secrets from git-ignored file using absolute path
      # The flake copies sources to /nix/store, excluding git-ignored files
      # So we use PWD or FLAKE_ROOT to find the original directory
      # Requires --impure flag for builds: nix build .#wsl-distro --impure
      flakeRoot = builtins.getEnv "FLAKE_ROOT";
      pwdPath = builtins.getEnv "PWD";

      # Try FLAKE_ROOT first, then PWD, construct path to secrets.nix
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
          defaultSecrets;

      inherit (customsecrets) username;

    in
    {
      nixosConfigurations = {
        desktop = nixpkgs.lib.nixosSystem {
          modules = [
            { nixpkgs.hostPlatform = system; }
            ./hosts/desktop
            # Apply overlays to nixpkgs for this configuration
            { nixpkgs.overlays = overlays ++ [ inputs.s4rchiso-plymouth.overlays.default ]; }
          ];
          specialArgs = {
            host = "desktop";
            inherit
              self
              inputs
              username
              customsecrets
              ;
          };
        };
        laptop = nixpkgs.lib.nixosSystem {
          modules = [
            { nixpkgs.hostPlatform = system; }
            ./hosts/laptop
            # Apply overlays to nixpkgs for this configuration
            { nixpkgs.overlays = overlays ++ [ inputs.s4rchiso-plymouth.overlays.default ]; }
          ];
          specialArgs = {
            host = "laptop";
            inherit
              self
              inputs
              username
              customsecrets
              ;
          };
        };
        vm = nixpkgs.lib.nixosSystem {
          modules = [
            { nixpkgs.hostPlatform = system; }
            ./hosts/vm
            # Apply overlays to nixpkgs for this configuration
            { nixpkgs.overlays = overlays; }
          ];
          specialArgs = {
            host = "vm";
            inherit
              self
              inputs
              username
              customsecrets
              ;
          };
        };
        vmware-guest = nixpkgs.lib.nixosSystem {
          modules = [
            { nixpkgs.hostPlatform = system; }
            ./hosts/vmware-guest
            # Apply overlays to nixpkgs for this configuration
            { nixpkgs.overlays = overlays; }
          ];
          specialArgs = {
            host = "nixos-vmware";
            inherit
              self
              inputs
              username
              customsecrets
              ;
          };
        };
        wsl = nixpkgs.lib.nixosSystem {
          modules = [
            { nixpkgs.hostPlatform = system; }
            ./hosts/wsl
            # Apply overlays to nixpkgs for this configuration
            { nixpkgs.overlays = overlays; }
          ];
          specialArgs = {
            host = "nixos-wsl";
            inherit
              self
              inputs
              username
              customsecrets
              ;
          };
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
