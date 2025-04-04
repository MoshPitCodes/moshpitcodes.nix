{ inputs, pkgs, ... }:
{
  home.packages = (
    with pkgs;
    [

      bruno

      # Go
      go

      # Java
      # corretto21

      # NodejS
      nodejs
      pnpm # Fast, disk space efficient package manager

      # OCaml
      ocaml
      ocamlPackages.ocaml-lsp # OCaml Language Server Protocol

      # Protobuf
      grpc
      protoc-gen-go # Go protobuf generator
      protoc-gen-go-grpc # Go gRPC generator
      protobuf # Protocol Buffers compiler

      # Python
      python3
      python312Packages.pip # Python package manager

      # Zig
      # inputs.zig.packages.${system}.master # zig compiler
      # zls # zig language server

      # IDE
      vscode
      code-cursor
      # jetbrains.idea-community-bin

      # Database
      # pgadmin4
      # sqlite
      # sqlitebrowser
      # postgresql
      go-migrate # database migration tool
      sqlc # SQL compiler

      # DevOps Tools
      # ansible
      # ansible-lint
      # ansible-review
      # awscli
      # aws-vault
      # azure-cli
      # doppler
      kubectl # k8s
      kubectx # switch between k8s contexts
      # kubernetes # k8s
      kubernetes-helm # k8s package manager
      # kustomize # k8s
      # minikube
      # kind
      # k3s
      # k9s
      nomad
      # opentofu
      # portainer
      # pulumi # Infrastructure as Code
      # pulumictl # pulumi cli
      rancher # k8s management
      # salt
      # salt-lint
      # stern # k8s log viewer
      # terraform
      # terraform-docs
      # terraform-ls
      # terraform-provider-tfe
      # terraform-provider-vault
      # terraform-provider-vsphere
      # terraform-provider-yaml
      # terraform-validator
      # terraform-workspace
      # tfenv # terraform version manager
      # tfsec # terraform security scanner
      # tflint # terraform linter
      # tfnotify # notify on terraform plan
      # tfswitch # terraform version manager
      # tfupdate # update terraform modules
      # tfwatch # watch terraform plan
      # veeam # backup and restore
      # velero # backup and restore for k8s
      yq # yaml processor
    ]
  );
}
