{ pkgs, lib, config, ... }:
let
  # Import shared extension definitions
  vscodeExtensions = import ./vscode-extensions.nix { inherit pkgs; };

  # Generate extensions.json content for VSCode workspace recommendations
  extensionsJson = builtins.toJSON {
    recommendations = vscodeExtensions.vscodeExtensions.ids;
    unwantedRecommendations = [ ];
  };

  # Generate a helper script to install extensions via code CLI
  installExtensionsScript = pkgs.writeShellScriptBin "vscode-install-extensions" ''
    #!/usr/bin/env bash
    # Script to install VSCode extensions from the declarative list
    # This works with Windows VSCode accessed via PATH

    set -e

    echo "Installing VSCode extensions for Remote-WSL..."
    echo ""

    # Check if code command is available (from Windows PATH in WSL)
    if ! command -v code.cmd &> /dev/null && ! command -v code &> /dev/null; then
      echo "Error: VSCode 'code' command not found in PATH"
      echo "Make sure Windows VSCode is installed and accessible from WSL"
      echo "You may need to add it to your PATH or run from Windows terminal"
      exit 1
    fi

    # Detect which command to use
    CODE_CMD="code"
    if command -v code.cmd &> /dev/null; then
      CODE_CMD="code.cmd"
    fi

    # List of extension IDs to install
    extensions=(
      ${lib.concatMapStringsSep "\n      " (id: ''"${id}"'') vscodeExtensions.vscodeExtensions.ids}
    )

    installed=0
    skipped=0
    failed=0

    for ext in "''${extensions[@]}"; do
      echo -n "Installing $ext... "
      if $CODE_CMD --install-extension "$ext" --force &> /dev/null; then
        echo "✓"
        ((installed++))
      else
        # Check if already installed
        if $CODE_CMD --list-extensions 2>/dev/null | grep -qi "^$ext$"; then
          echo "already installed"
          ((skipped++))
        else
          echo "✗ failed"
          ((failed++))
        fi
      fi
    done

    echo ""
    echo "Summary:"
    echo "  Installed: $installed"
    echo "  Already installed: $skipped"
    echo "  Failed: $failed"
    echo ""

    if [ $failed -gt 0 ]; then
      echo "Some extensions failed to install. Try running the command manually:"
      echo "  code --install-extension <extension-id>"
      exit 1
    fi

    echo "✓ All extensions installed successfully!"
  '';

  # Generate a settings snippet for WSL-specific paths
  wslSettingsSnippet = {
    # Terminal settings for WSL
    "terminal.integrated.defaultProfile.linux" = "zsh";
    "terminal.integrated.profiles.linux" = {
      zsh = {
        path = "${pkgs.zsh}/bin/zsh";
        icon = "terminal";
      };
      bash = {
        path = "${pkgs.bash}/bin/bash";
        icon = "terminal-bash";
      };
    };

    # Git configuration
    "git.path" = "${pkgs.git}/bin/git";

    # Language-specific settings pointing to WSL tools
    "go.goroot" = lib.mkIf (builtins.hasAttr "go" pkgs) "${pkgs.go}/share/go";
    "go.gopath" = "\${env:HOME}/go";
    "rust-analyzer.server.path" = lib.mkIf (builtins.hasAttr "rust-analyzer" pkgs) "${pkgs.rust-analyzer}/bin/rust-analyzer";
    "python.defaultInterpreterPath" = lib.mkIf (builtins.hasAttr "python3" pkgs) "${pkgs.python3}/bin/python";
    "zig.path" = lib.mkIf (builtins.hasAttr "zig" pkgs) "${pkgs.zig}/bin/zig";
    "zig.zls.path" = lib.mkIf (builtins.hasAttr "zls" pkgs) "${pkgs.zls}/bin/zls";

    # Nix IDE settings
    "nix.enableLanguageServer" = true;
    "nix.serverPath" = lib.mkIf (builtins.hasAttr "nil" pkgs) "${pkgs.nil}/bin/nil";
    "nix.formatterPath" = lib.mkIf (builtins.hasAttr "nixpkgs-fmt" pkgs) "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt";

    # Remote-WSL specific settings
    "remote.WSL.fileWatcher.polling" = true;
    "remote.WSL.useShellEnvironment" = true;
  };
in
{
  # Create extensions.json in the default project location
  # Users can copy this to their project's .vscode/ directory
  home.file.".vscode-remote/extensions.json".text = extensionsJson;

  # Create WSL-specific settings snippet
  home.file.".vscode-remote/wsl-settings.json".text = builtins.toJSON wslSettingsSnippet;

  # Create README for users
  home.file.".vscode-remote/README.md".text = ''
    # VSCode Remote-WSL Extension Configuration

    This directory contains VSCode configuration files for use with Remote-WSL.

    ## Files

    - `extensions.json` - Recommended extensions list
    - `wsl-settings.json` - WSL-specific settings snippet
    - `install-extensions.sh` - Helper script to install all extensions

    ## Usage

    ### Option 1: Use extensions.json in your projects

    Copy `extensions.json` to your project's `.vscode/` directory:

    ```bash
    cp ~/.vscode-remote/extensions.json ~/your-project/.vscode/
    ```

    Windows VSCode will prompt you to install the recommended extensions when you open the project.

    ### Option 2: Install all extensions at once

    Run the helper script to install all extensions:

    ```bash
    vscode-install-extensions
    ```

    This requires Windows VSCode to be accessible from WSL PATH.

    ### Option 3: Merge WSL settings

    Add the contents of `wsl-settings.json` to your VSCode settings:

    ```bash
    cat ~/.vscode-remote/wsl-settings.json
    ```

    Then copy the relevant settings to your VSCode User settings.

    ## Extension List

    The extension list is declaratively managed in your NixOS configuration at:
    `modules/home/vscode-extensions.nix`

    To add or remove extensions, edit that file and run `nixos-rebuild switch`.

    ## Keeping Extensions in Sync

    Your extensions are defined once in Nix and can be used:
    1. On desktop Linux with full VSCode installation
    2. In WSL with Windows VSCode via Remote-WSL
    3. Via SSH with Remote-SSH

    The same extension list is shared across all environments!
  '';

  # Add the install script to PATH
  home.packages = [ installExtensionsScript ];

  # Create a symlink script for easy access
  home.file.".vscode-remote/install-extensions.sh".source = "${installExtensionsScript}/bin/vscode-install-extensions";
}
