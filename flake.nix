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
      # inputs.nixpkgs.follows = "nixpkgs";
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
  };

  outputs =
    { nixpkgs, self, ... }@inputs:
    let
      system = "x86_64-linux";

      # Import custom overlays for package version overrides
      overlays = import ./overlays { inherit inputs; };

      pkgs = import nixpkgs {
        inherit system overlays;
        config.allowUnfree = true;
      };

      # Load secrets with fallback defaults for CI/testing environments
      defaultSecrets = {
        username = "testuser";
        # Default test hash (password: "testpassword")
        hashedPassword = "$6$test$test";
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

      # Validate that secrets have all required keys
      validateSecrets = secrets:
        let
          requiredKeys = [ "username" "hashedPassword" "git" "network" ];
          missingKeys = builtins.filter (k: !(builtins.hasAttr k secrets)) requiredKeys;
        in
        if missingKeys == [ ] then
          secrets
        else
          throw "secrets.nix missing required keys: ${builtins.toString missingKeys}";

      customsecrets =
        if builtins.pathExists ./secrets.nix then
          validateSecrets (import ./secrets.nix)
        else
          defaultSecrets;

      username = customsecrets.username;

    in
    {
      nixosConfigurations = {
        desktop = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/desktop
            # Apply overlays to nixpkgs for this configuration
            { nixpkgs.overlays = overlays; }
          ];
          specialArgs = {
            host = "desktop";
            inherit self inputs username customsecrets;
          };
        };
        laptop = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/laptop
            # Apply overlays to nixpkgs for this configuration
            { nixpkgs.overlays = overlays; }
          ];
          specialArgs = {
            host = "laptop";
            inherit self inputs username customsecrets;
          };
        };
        vm = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/vm
            # Apply overlays to nixpkgs for this configuration
            { nixpkgs.overlays = overlays; }
          ];
          specialArgs = {
            host = "vm";
            inherit self inputs username customsecrets;
          };
        };
        vmware-guest = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/vmware-guest
            # Apply overlays to nixpkgs for this configuration
            { nixpkgs.overlays = overlays; }
          ];
          specialArgs = {
            host = "nixos-vmware";
            inherit self inputs username customsecrets;
          };
        };
        wsl = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/wsl
            # Apply overlays to nixpkgs for this configuration
            { nixpkgs.overlays = overlays; }
          ];
          specialArgs = {
            host = "nixos-wsl";
            inherit self inputs username customsecrets;
          };
        };
      };

      packages.${system}.wsl-distro = self.nixosConfigurations.wsl.config.system.build.tarballBuilder;

      devShells.${system} = {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [
            treefmt
            nixfmt-rfc-style
            shfmt
            deadnix
            statix
          ];
          shellHook = ''
            echo "🚀 NixOS Development Environment"
            echo "Available commands:"
            echo "  treefmt        - Format all files"
            echo "  treefmt --fail-on-change - Check if files are formatted"
            echo "  nixfmt-rfc-style - Format Nix files"
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
