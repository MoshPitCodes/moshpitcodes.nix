{ inputs }:
[
  # Sidecar - TUI companion for AI coding workflows
  (import ./sidecar.nix { inherit inputs; })

  # TD - Task management for AI-assisted development
  (import ./td.nix { inherit inputs; })

  # LibreOffice - workaround for noto-fonts-subset build failure (nixpkgs bug)
  (import ./libreoffice.nix { inherit inputs; })

  # Reposync - disabled (re-enable when needed)
  # (import ./reposync.nix { inherit inputs; })
]
