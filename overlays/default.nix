{ inputs }:
[
  # Development tools with version overrides
  # This includes Terraform, and can be extended with more tools as needed
  (import ./development-tools.nix { inherit inputs; })

  # Add additional overlay modules here:
  # (import ./python-packages.nix { inherit inputs; })
  # (import ./kubernetes-tools.nix { inherit inputs; })
  # (import ./nodejs-tools.nix { inherit inputs; })

  # External overlays (e.g., NUR) can be added here:
  # inputs.nur.overlays.default
]
