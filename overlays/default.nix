{ inputs }:
[
  # Sidecar - TUI companion for AI coding workflows
  (import ./sidecar.nix { inherit inputs; })

  # TD - Task management for AI-assisted development
  (import ./td.nix { inherit inputs; })

  # Worktrunk - Git worktree management for parallel AI agent workflows
  (import ./worktrunk.nix { inherit inputs; })

  # Reposync - disabled (re-enable when needed)
  # (import ./reposync.nix { inherit inputs; })
]
