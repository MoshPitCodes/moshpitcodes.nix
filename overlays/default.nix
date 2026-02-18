{ inputs }:
[
  # Sidecar - TUI companion for AI coding workflows
  (import ./sidecar.nix { inherit inputs; })

  # TD - Task management for AI-assisted development
  (import ./td.nix { inherit inputs; })

  # Reposync - Interactive repository synchronization tool
  (import ./reposync.nix { inherit inputs; })
]
