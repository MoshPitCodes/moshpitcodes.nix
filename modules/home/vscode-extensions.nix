# VS Code extension definitions
{ pkgs, ... }:
let
  vscode-utils = pkgs.vscode-utils;

  # Custom marketplace extensions not in nixpkgs
  # TODO: Add Kiro VS Code extension when available in nixpkgs
  # (Not yet available in nixpkgs or VS Code marketplace as of 2026-03-04)
  customExtensions = {
    everforest = vscode-utils.buildVscodeMarketplaceExtension {
      mktplcRef = {
        name = "everforest";
        publisher = "sainnhe";
        version = "0.3.0";
        hash = "sha256-nZirzVvM160ZTpBLTimL2X35sIGy5j2LQOok7a2Yc7U=";
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

    kilo-code = vscode-utils.buildVscodeMarketplaceExtension {
      mktplcRef = {
        name = "kilo-code";
        publisher = "kilocode";
        version = "5.10.0";
        hash = "sha256-DWtBaj5QWBqYpSxLUJNM+uuq79KMoc0Wjhq3q3HWp4c=";
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
        everforest
        claude-code
        kilo-code
        makefile-tools
        vscode-mermaid-chart
        vscode-zig
      ]);
  };
}
