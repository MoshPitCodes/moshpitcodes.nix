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
        nixfmt # nix formatter
        nix-prefetch-github # fetch GitHub repositories
        nix-output-monitor # nix build output monitor
        nvd # nix generation diff tool
        inputs.alejandra.defaultPackage.${pkgs.stdenv.hostPlatform.system} # alejandra formatter

        # API Testing
        bruno # API testing tool

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

        # Containerization
        # Docker daemon is enabled in core/virtualization.nix
        docker-compose # docker compose tool
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
        gradle_9 # Gradle build tool for Java
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
        uv # Astral UV - fast Python package and project manager

        # Secrets Management
        doppler # secrets management
      ]
      # Conditionally include vscode for non-WSL hosts (managed by vscode.nix)
      ++ lib.optionals (host != "nixos-wsl") [ pkgs.vscode ];
  };
}
