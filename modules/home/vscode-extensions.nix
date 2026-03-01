# VS Code extension definitions
{ pkgs, ... }:
let
  vscode-utils = pkgs.vscode-utils;

  # Custom marketplace extensions not in nixpkgs
  customExtensions = {
    tokyo-night = vscode-utils.buildVscodeMarketplaceExtension {
      mktplcRef = {
        name = "tokyo-night";
        publisher = "enkia";
        version = "1.0.5";
        hash = "sha256-uQ/IaZMOs9vQen22+t7CeuY54Xgh7s+UP4skhQyMgGU=";
      };
    };

    claude-code = vscode-utils.buildVscodeMarketplaceExtension {
      mktplcRef = {
        name = "claude-code";
        publisher = "anthropic";
        version = "2.1.49";
        hash = "sha256-9WwA1TUM/h8kLoZV/ukh/4s3w9DnJ/cVAxypz4jlj6A=";
      };
    };

    makefile-tools = vscode-utils.buildVscodeMarketplaceExtension {
      mktplcRef = {
        name = "makefile-tools";
        publisher = "ms-vscode";
        version = "0.13.6";
        hash = "sha256-hGd+yg6sx5lMq7KTl1oghZvYRwaydMT44xhV1Rhb64c=";
      };
    };

    vscode-mermaid-chart = vscode-utils.buildVscodeMarketplaceExtension {
      mktplcRef = {
        name = "vscode-mermaid-chart";
        publisher = "MermaidChart";
        version = "2.5.3";
        hash = "sha256-JqHVqMGeE1FYY9Q5U4Q01H8K7C2gXs+YAV08ZzABgZM=";
      };
    };

    vscode-zig = vscode-utils.buildVscodeMarketplaceExtension {
      mktplcRef = {
        name = "vscode-zig";
        publisher = "ziglang";
        version = "0.6.10";
        hash = "sha256-Tptl+tJ2ZlnKyswdTjnPJakhiiJn+1XmB82rbk8aO1w=";
      };
    };
  };
in
{
  vscodeExtensions = {
    packages =
      (with pkgs.vscode-extensions; [
        # Language support
        golang.go
        jnoortheen.nix-ide
        ms-python.python
        ms-vscode.cpptools
        redhat.vscode-yaml
        redhat.ansible
        redhat.java
        esbenp.prettier-vscode
        timonwong.shellcheck
        foxundermoon.shell-format
        hashicorp.terraform
        hashicorp.hcl
        ms-azuretools.vscode-docker
        ms-kubernetes-tools.vscode-kubernetes-tools
        dbaeumer.vscode-eslint
        ocamllabs.ocaml-platform

        # GitHub
        github.copilot
        github.copilot-chat
        github.vscode-pull-request-github

        # Markdown
        yzhang.markdown-all-in-one
        bierner.markdown-mermaid

        # Editor enhancements
        eamodio.gitlens
        streetsidesoftware.code-spell-checker
        jgclark.vscode-todo-highlight

        # Icons
        pkief.material-icon-theme
      ])
      ++ (with customExtensions; [
        tokyo-night
        claude-code
        makefile-tools
        vscode-mermaid-chart
        vscode-zig
      ]);
  };
}
