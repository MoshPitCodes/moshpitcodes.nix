{ pkgs, ... }:
let
  # Custom VSCode extensions that need to be built
  customExtensions = {
    gruvbox-material-icon-theme = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
      mktplcRef = {
        name = "gruvbox-material-icon-theme";
        publisher = "JonathanHarty";
        version = "1.1.5";
        hash = "sha256-86UWUuWKT6adx4hw4OJw3cSZxWZKLH4uLTO+Ssg75gY=";
      };
    };

    vscode-zig = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
      mktplcRef = {
        name = "vscode-zig";
        publisher = "ziglang";
        version = "0.6.10";
        hash = "sha256-Tptl+tJ2ZlnKyswdTjnPJakhiiJn+1XmB82rbk8aO1w=";
      };
    };

    claude-code = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
      mktplcRef = {
        name = "claude-code";
        publisher = "anthropic";
        version = "1.0.31";
        hash = "sha256-3brSSb6ERY0In5QRmv5F0FKPm7Ka/0wyiudLNRSKGBg=";
      };
    };

    makefile-tools = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
      mktplcRef = {
        name = "makefile-tools";
        publisher = "ms-vscode";
        version = "0.13.6";
        hash = "sha256-hGd+yg6sx5lMq7KTl1oghZvYRwaydMT44xhV1Rhb64c=";
      };
    };

    geminicodeassist = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
      mktplcRef = {
        name = "geminicodeassist";
        publisher = "Google";
        version = "2.38.0";
        hash = "sha256-B9YgvSAjvVc0CMt4JPkj0BqJdDG2Ie+DXC7Mv4O/ia8=";
      };
    };

    vscode-mermaid-chart = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
      mktplcRef = {
        name = "vscode-mermaid-chart";
        publisher = "MermaidChart";
        version = "2.5.3";
        hash = "sha256-JqHVqMGeE1FYY9Q5U4Q01H8K7C2gXs+YAV08ZzABgZM=";
      };
    };
  };

  # List of all extensions (for programs.vscode.extensions)
  # These are from pkgs.vscode-extensions or custom built above
  extensionsList = with pkgs.vscode-extensions; [
    # Custom built extensions
    customExtensions.makefile-tools
    customExtensions.claude-code
    customExtensions.geminicodeassist
    customExtensions.vscode-mermaid-chart
    customExtensions.vscode-zig
    customExtensions.gruvbox-material-icon-theme

    # Official Microsoft extensions
    ms-azuretools.vscode-docker
    ms-kubernetes-tools.vscode-kubernetes-tools
    ms-python.python

    # 3rd party extensions
    dbaeumer.vscode-eslint
    github.copilot
    github.copilot-chat
    github.vscode-pull-request-github
    golang.go
    hashicorp.hcl
    hashicorp.terraform
    bierner.markdown-mermaid
    jnoortheen.nix-ide
    ocamllabs.ocaml-platform
    esbenp.prettier-vscode
    jgclark.vscode-todo-highlight
    redhat.ansible
    redhat.java
    redhat.vscode-yaml
    yzhang.markdown-all-in-one
    jdinhlife.gruvbox
  ];

  # Extension identifiers for recommendations (publisher.extension-id format)
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
in
{
  # Export both the extension packages and their IDs
  vscodeExtensions = {
    # For use in programs.vscode.extensions
    packages = extensionsList;

    # For use in extensions.json recommendations
    ids = extensionIds;

    # Custom extensions that may need to be referenced directly
    custom = customExtensions;
  };
}
