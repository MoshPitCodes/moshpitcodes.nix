{ pkgs, lib, ... }:
let
  # For WSL remote, we only need extension IDs, not the actual packages
  # This avoids building VSCode and extensions which are not used in WSL
  extensionIds = [
    # Custom extensions
    "ms-vscode.makefile-tools"
    "anthropic.claude-code"
    "Google.geminicodeassist"
    "MermaidChart.vscode-mermaid-chart"
    "ziglang.vscode-zig"
    "JonathanHarty.gruvbox-material-icon-theme"

    # Official Microsoft extensions
    "ms-azuretools.vscode-docker"
    "ms-kubernetes-tools.vscode-kubernetes-tools"
    "ms-python.python"

    # 3rd party extensions
    "dbaeumer.vscode-eslint"
    "github.copilot"
    "github.copilot-chat"
    "github.vscode-pull-request-github"
    "golang.go"
    "hashicorp.hcl"
    "hashicorp.terraform"
    "bierner.markdown-mermaid"
    "jnoortheen.nix-ide"
    "ocamllabs.ocaml-platform"
    "esbenp.prettier-vscode"
    "jgclark.vscode-todo-highlight"
    "redhat.ansible"
    "redhat.java"
    "redhat.vscode-yaml"
    "yzhang.markdown-all-in-one"
    "jdinhlife.gruvbox"
  ];

  # Generate extensions.json content for VSCode workspace recommendations
  extensionsJson = builtins.toJSON {
    recommendations = extensionIds;
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
      ${lib.concatMapStringsSep "\n      " (id: ''"${id}"'') extensionIds}
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
    "go.goroot" = "${pkgs.go}/share/go";
    "go.gopath" = "\${env:HOME}/go";
    "rust-analyzer.server.path" = "${pkgs.rust-analyzer}/bin/rust-analyzer";
    "python.defaultInterpreterPath" = "${pkgs.python3}/bin/python";
    "zig.path" = "${pkgs.zig}/bin/zig";
    # "zig.zls.path" = "${pkgs.zls}/bin/zls"; # Temporarily disabled due to build issues

    # Nix IDE settings
    "nix.enableLanguageServer" = true;
    "nix.serverPath" = "${pkgs.nil}/bin/nil";
    "nix.formatterPath" = "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt";

    # Remote-WSL specific settings
    "remote.WSL.fileWatcher.polling" = true;
    "remote.WSL.useShellEnvironment" = true;
  };
in
{
  home = {
    # Add the install script to PATH
    packages = [ installExtensionsScript ];

    file = {
      # Create extensions.json in the default project location
      # Users can copy this to their project's .vscode/ directory
      ".vscode-remote/extensions.json".text = extensionsJson;

      # Create WSL-specific settings snippet
      ".vscode-remote/wsl-settings.json".text = builtins.toJSON wslSettingsSnippet;

      # Create README for users
      ".vscode-remote/README.md".text = ''
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

      # Create a symlink script for easy access
      ".vscode-remote/install-extensions.sh".source = "${installExtensionsScript}/bin/vscode-install-extensions";
    };
  };
}
