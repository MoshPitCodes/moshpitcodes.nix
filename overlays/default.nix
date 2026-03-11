{ inputs }:
[
  # Faugus Launcher - override to 1.16.2 (nixpkgs has 1.15.10)
  (import ./faugus-launcher.nix { })

  # Sidecar - TUI companion for AI coding workflows
  (import ./sidecar.nix { inherit inputs; })

  # TD - Task management for AI-assisted development
  (import ./td.nix { inherit inputs; })

  # Worktrunk - Git worktree management for parallel AI agent workflows
  (import ./worktrunk.nix { inherit inputs; })

  # Reposync - disabled (re-enable when needed)
  # (import ./reposync.nix { inherit inputs; })
]
