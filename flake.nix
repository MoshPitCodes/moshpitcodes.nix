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
  };

  outputs =
    { nixpkgs, self, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      customsecrets = import ./secrets.nix;
      username = customsecrets.username;

    in
    {
      nixosConfigurations = {
        desktop = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [ ./hosts/desktop ];
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
          inherit system;
          modules = [ ./hosts/laptop ];
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
          inherit system;
          modules = [ ./hosts/vm ];
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
          inherit system;
          modules = [ ./hosts/vmware-guest ];
          specialArgs = {
            host = "vmware";
            inherit
              self
              inputs
              username
              customsecrets
              ;
          };
        };
      };

      devShells.${system}.default = pkgs.mkShell {
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
    };
}
