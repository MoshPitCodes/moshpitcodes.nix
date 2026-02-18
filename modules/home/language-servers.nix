# Centralized Language Server Protocol (LSP) configuration
# This module consolidates all language server tools and configurations
# shared across editors (neovim, vscode, etc.)
{ pkgs, lib, ... }:
let
  # Language server enablement flags
  # Set to false to disable a language completely
  languages = {
    c-cpp = true;
    css = true;
    go = true;
    html = false; # Disabled due to superhtml build issues
    java = true;
    javascript-typescript = true;
    lua = true;
    nix = true;
    python = true;
    rust = true;
    shell = true;
    yaml = true;
    zig = false; # Disabled due to zls build issues
  };

  # Language server packages
  # Organized by language for easy maintenance
  lspPackages =
    with pkgs;
    lib.optionals languages.c-cpp [
      clang-tools # clangd LSP, clang-format, clang-tidy
      cmake-language-server
    ]
    ++ lib.optionals languages.css [
      vscode-langservers-extracted # cssls, html, json, eslint
    ]
    ++ lib.optionals languages.go [
      gopls # Go LSP
      golangci-lint # Go linter
      gofumpt # Go formatter
      delve # Go debugger
    ]
    ++ lib.optionals languages.html [
      # superhtml # Disabled due to build issues
    ]
    ++ lib.optionals languages.java [
      jdt-language-server # Java LSP
    ]
    ++ lib.optionals languages.javascript-typescript [
      nodePackages.typescript-language-server # tsserver
      nodePackages.vscode-langservers-extracted # eslint
      nodePackages."@tailwindcss/language-server" # tailwindcss
      prettierd # Formatter daemon
    ]
    ++ lib.optionals languages.lua [
      lua-language-server # lua-ls
      stylua # Lua formatter
    ]
    ++ lib.optionals languages.nix [
      nixd # Nix LSP (modern, recommended)
      nil # Alternative Nix LSP
      nixfmt # Nix formatter (RFC 166 style)
      statix # Nix linter
      deadnix # Dead code elimination
    ]
    ++ lib.optionals languages.python [
      pyright # Python LSP
      ruff # Python linter & formatter
      black # Python formatter
    ]
    ++ lib.optionals languages.rust [
      rust-analyzer # Rust LSP
      rustfmt # Rust formatter
      clippy # Rust linter
    ]
    ++ lib.optionals languages.shell [
      shellcheck # Shell linter
      shfmt # Shell formatter
      nodePackages.bash-language-server # bashls
    ]
    ++ lib.optionals languages.yaml [
      yaml-language-server # yamlls
    ]
    ++ lib.optionals languages.zig [
      # zls # Disabled due to build issues
    ];

  # Additional development tools (not LSPs but related)
  devTools = with pkgs; [
    # Debuggers
    gdb # C/C++ debugger

    # Build tools
    gnumake
    cmake
    meson
    ninja

    # Version control
    pre-commit

    # API testing
    bruno
  ];
in
{
  # Install all enabled language servers
  home.packages = lspPackages ++ devTools;

  # Export language enablement for other modules to use
  # This allows nvim.nix and vscode.nix to check which languages are enabled
  home.sessionVariables = {
    LSP_C_CPP_ENABLED = if languages.c-cpp then "1" else "0";
    LSP_CSS_ENABLED = if languages.css then "1" else "0";
    LSP_GO_ENABLED = if languages.go then "1" else "0";
    LSP_HTML_ENABLED = if languages.html then "1" else "0";
    LSP_JAVA_ENABLED = if languages.java then "1" else "0";
    LSP_JS_TS_ENABLED = if languages.javascript-typescript then "1" else "0";
    LSP_LUA_ENABLED = if languages.lua then "1" else "0";
    LSP_NIX_ENABLED = if languages.nix then "1" else "0";
    LSP_PYTHON_ENABLED = if languages.python then "1" else "0";
    LSP_RUST_ENABLED = if languages.rust then "1" else "0";
    LSP_SHELL_ENABLED = if languages.shell then "1" else "0";
    LSP_YAML_ENABLED = if languages.yaml then "1" else "0";
    LSP_ZIG_ENABLED = if languages.zig then "1" else "0";
  };

  # Make the language enablement available to other modules
  _module.args.lspLanguages = languages;
}
