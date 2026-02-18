# Development toolchains and utilities
{
  pkgs,
  lib,
  host,
  ...
}:
{
  home.packages =
    with pkgs;
    [
      # Language runtimes (compilers/interpreters)
      # Note: LSP servers, formatters, linters are in language-servers.nix
      gcc # C/C++ compiler
      go # Go compiler
      go-migrate # Database migration tool
      openjdk25 # Java runtime
      nodejs # JavaScript/Node runtime
      typescript # TypeScript compiler
      bun # Fast all-in-one JavaScript runtime
      python3 # Python interpreter
      uv # Fast Python package installer
      rustc # Rust compiler
      cargo # Rust package manager
      zig # Zig compiler

      # Build tools
      gradle_9 # Java build tool
      maven # Java build tool

      # Nix utilities
      nix-prefetch-github
      nix-output-monitor
      nvd

      # Database
      postgresql
      sqlc

      # Cloud & Infrastructure
      azure-cli
      doppler
      terraform
      terraform-docs
      terraform-ls
      tflint
      tfsec
      ansible

      # Kubernetes
      kubectl
      kubernetes
      k9s
      helm
      kubectx
      rancher
      talosctl
      cilium-cli

      # Container tools
      docker-compose

      # Protobuf
      grpc
      protobuf
      protoc-gen-go
      protoc-gen-go-grpc

      # Utilities
      jq
      yq
      ripgrep
    ]
    ++ lib.optionals (host != "wsl") [
      # Desktop-only dev tools (not for WSL)
    ];
}
