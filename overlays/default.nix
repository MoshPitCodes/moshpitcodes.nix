{ inputs }:
[
  # Development tools with version overrides
  # This includes Terraform, and can be extended with more tools as needed
  (import ./development-tools.nix { })

  # Sidecar - TUI companion for AI coding workflows
  (import ./sidecar.nix { inherit inputs; })

  # TD - Task management for AI-assisted development
  (import ./td.nix { inherit inputs; })

  # Add additional overlay modules here:
  # (import ./python-packages.nix { })
  # (import ./kubernetes-tools.nix { })
  # (import ./nodejs-tools.nix { })

  # External overlays
  inputs.nur.overlays.default
]
