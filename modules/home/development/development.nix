{
  inputs,
  pkgs,
  lib,
  host,
  ...
}:
{
  home = {
    packages =
      with pkgs;
      [
        # C / C++
        gcc # C compiler
        gdb # C debugger
        gnumake # C build tool

        # Nix
        nixd # nix lsp
        nixfmt-rfc-style # nix formatter
        nix-prefetch-github # fetch GitHub repositories
        inputs.alejandra.defaultPackage.${pkgs.stdenv.hostPlatform.system} # alejandra formatter

        # API Testing
        bruno # API testing tool

        # CLI Agents
        claude-code # Anthropic's Claude Code CLI
        gemini-cli # Google Gemini CLI
        opencode # OpenCode CLI for AI-assisted development

        # Cloud CLIs
        # awscli
        # aws-vault
        azure-cli # Azure CLI

        # Command Line Tools
        jq # JSON processor
        yq # yaml processor
        ripgrep # fast text search tool
        shfmt # bash formatter
        pre-commit # Framework for managing pre-commit hooks

        # Configuration Management
        # salt
        # salt-lint
        # stern # k8s log viewer
        # ansible # Configuration management tool
        # ansible-lint # Ansible linter

        # Containerization (installed in user.nix)
        # docker # container management (configured in user.nix and virtualization.nix)
        # docker-compose # docker compose tool (configured in user.nix and virtualization.nix)
        # podman # container management
        # podman-compose # podman compose tool
        # portainer

        # Databases
        # pgadmin4 # PostgreSQL database management tool
        # sqlite # SQLite database engine
        # sqlitebrowser # SQLite database browser
        sqlc # SQL compiler
        postgresql # PostgreSQL database server

        # Go
        go # Go programming language
        go-migrate # database migration tool
        gopls # Go language server
        golangci-lint # Go linter
        gofumpt # Go code formatter

        # IDE
        # jetbrains.android-studio # Android Studio
        # jetbrains.clion-community-bin # CLion Community Edition
        # jetbrains.datagrip-community-bin # DataGrip Community Edition
        # jetbrains.goland-community-bin # GoLand Community Edition
        # jetbrains.idea-community-bin # JetBrains IDE Community Edition
        # jetbrains.kotlinc # Kotlin compiler
        # jetbrains.kotlinc-format # Kotlin code formatter
        # jetbrains.kotlinc-language-server # Kotlin Language Server
        # jetbrains.kotlinc-lsp # Kotlin Language Server Protocol
        # jetbrains.phpstorm-community-bin # PhpStorm Community Edition
        # jetbrains.pycharm-community-bin # PyCharm Community Edition
        # jetbrains.rider-community-bin # Rider Community Edition
        # jetbrains.rubymine-community-bin # RubyMine Community Edition
        # jetbrains.webstorm-community-bin # WebStorm Community Edition

        # Infrastructure as Code
        ansible # Configuration management
        # nomad # HashiCorp's workload orchestrator
        # opentofu # Infrastructure as Code
        # opentofu-ls # OpenTofu Language Server
        # pulumi # Infrastructure as Code
        # pulumictl # pulumi cli
        # terraform-validator # validate Terraform configurations
        # terraform-workspace # manage Terraform workspaces
        # tfenv # terraform version manager
        # tfnotify # notify on terraform plan
        tfsec # terraform security scanner
        # tfswitch # terraform version manager
        # tfupdate # update terraform modules
        # tfwatch # watch terraform plan
        terraform # Infrastructure as Code (version 1.14.0 via overlay)
        terraform-docs # generate documentation from Terraform modules
        terraform-ls # Terraform Language Server
        tflint # terraform linter

        # Java
        # corretto21 # Amazon Corretto 21 (OpenJDK 21)
        gradle # Gradle build tool for Java
        maven # Maven build tool for Java
        openjdk25

        # JavaScript
        # deno # Deno runtime for JavaScript and TypeScript
        typescript # TypeScript compiler
        typescript-language-server # TypeScript Language Server

        # Kubernetes
        # kind # k8s in docker
        # knative # k8s serverless framework
        # kustomize # k8s
        # minikube # local k8s cluster
        # velero # backup and restore for k8s
        cilium-cli # Cilium CNI and service mesh CLI
        # k3d # k3s in docker
        # k3s # lightweight k8s
        k9s # k8s terminal UI
        kubectl # is also provided by k3s package
        talosctl # Talos Linux CLI
        kubectx # switch between k8s contexts
        kubernetes # k8s
        kubernetes-helm # Helm package manager for Kubernetes
        rancher # k8s management

        # NodejS
        bun # Alternative JavaScript runtime and package manager
        # npm # Node.js package manager
        # yarn # Alternative Node.js package manager
        nodejs # Node.js runtime
        # pnpm # Fast, disk space efficient package manager

        # OCaml
        # ocaml # OCaml programming language
        # ocamlPackages.ocaml-lsp # OCaml Language Server Protocol
        # ocamlPackages.ocamlformat # OCaml code formatter

        # Rust
        # rust-analyzer # Rust language server
        # rustup # Rust toolchain installer
        rustc # Rust compiler
        cargo # Rust package manager
        rustfmt # Rust code formatter
        clippy # Rust linter

        # Zig
        zig # Zig programming language
        zls # zig language server

        # Protobuf
        grpc
        protoc-gen-go # Go protobuf generator
        protoc-gen-go-grpc # Go gRPC generator
        protobuf # Protocol Buffers compiler

        # Python
        python3 # Python 3 interpreter

        # Secrets Management
        doppler # secrets management
      ]
      # Conditionally include vscode for non-WSL hosts (managed by vscode.nix)
      ++ lib.optionals (host != "nixos-wsl") [ pkgs.vscode ];

    # Create configuration directories for AI Coding Agents
    file = {
      ".config/opencode/.gitkeep".text = "";
      ".config/claude-code/.gitkeep".text = "";

      # Claude Code configuration for Claude Pro
      ".config/claude-code/config.json".text = builtins.toJSON {
        # Use Claude Pro subscription model
        model = "claude-4-sonnet-20250514";
        # Claude Pro doesn't require API key - uses web authentication
        auth_method = "web";

        # Optional settings
        max_tokens = 8192;
        temperature = 0.7;

        # Enable features available with Claude Pro
        features = {
          code_execution = true;
          file_uploads = true;
          web_search = true;
        };
      };

      # OpenCode configuration file
      # API key is set via ANTHROPIC_API_KEY environment variable
      # Model format: provider/model (e.g., anthropic/claude-opus-4-5-20251101)
      ".config/opencode/config.json".text = builtins.toJSON {
        "$schema" = "https://opencode.ai/config.json";
        model = "anthropic/claude-opus-4-5-20251101";
      };
    };

    # Environment variables for API keys
    # Option 1: Set them in your shell configuration
    # WARNING: NOT RECOMMENDED if you are using a public repository
    sessionVariables = {
      # Uncomment and set your actual API keys here, or use a secrets manager
      # ANTHROPIC_API_KEY = "your-claude-api-key";
      # OPENAI_API_KEY = "your-openai-api-key";
    };
  };

  # Option 2: If using zsh with Doppler
  programs.zsh.shellAliases = {
    # opencode configuration with Doppler
    opencode-setup = ''
      echo "Setting up OpenCode with Doppler..."
      echo "Fetching API keys from Doppler..."
      export ANTHROPIC_API_KEY=$(doppler secrets get ANTHROPIC_API_KEY --plain)
      echo "Claude API keys loaded from Doppler"
    '';

    # Alternative: Run opencode with Doppler directly
    opencode-doppler = "doppler run -- opencode";

    # gemini-cli configuration with Doppler
    gemini-setup = ''
      echo "Setting up Gemini CLI with Doppler..."
      export GEMINI_API_KEY=$(doppler secrets get GEMINI_API_KEY --plain)
      echo "Gemini API key loaded from Doppler"
    '';

    # Alternative: Run gemini-cli with Doppler directly
    gemini-doppler = "doppler run -- gemini";

    # claude-code configuration with Claude Pro
    claude-code-setup = ''
      echo "Setting up Claude Code with Claude Pro..."
      echo "Run 'claude-code auth' to authenticate with your Claude Pro account"
    '';

    # Option 3: Use a shell alias to set API keys from a secure source
    # programs.bash.shellAliases = {
    #   opencode-setup = ''
    #     echo "Setting up OpenCode..."
    #     echo "Please set your API keys:"
    #     echo "export ANTHROPIC_API_KEY='your-key-here'"
    #     echo "export OPENAI_API_KEY='your-key-here'"
    #   '';
    # };
  };
}
