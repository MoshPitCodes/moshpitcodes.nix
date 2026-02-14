{ inputs }:
final: prev: {
  sidecar = prev.buildGoModule rec {
    pname = "sidecar";
    version = "0.71.1";

    src = inputs.sidecar;

    # Go module vendoring hash
    # Computed from go.mod and go.sum
    vendorHash = "sha256-R/AjNJ4x4t1zXXzT+21cjY+9pxs4DVXU4xs88BQvHx4=";

    # Only build the main sidecar binary
    subPackages = [ "cmd/sidecar" ];

    # Build flags - set version info
    ldflags = [
      "-s"
      "-w"
      "-X main.Version=${version}"
    ];

    # CGO is required for some dependencies (sqlite)
    env.CGO_ENABLED = "1";

    meta = with prev.lib; {
      description = "TUI companion for AI coding workflows - git status, file browser, task management, and conversation history";
      longDescription = ''
        Sidecar is a terminal UI (TUI) application designed to work alongside
        AI coding agents like Claude Code, Cursor, and OpenCode. It provides:

        - Git status and diff viewing with syntax highlighting
        - File browser with code preview
        - Conversation history from multiple AI agents
        - TD (task management) integration for AI-assisted workflows
        - Workspace management with git worktree support
        - Project and worktree switching
        - Customizable themes (built-in and community)

        Perfect for split-terminal setups where you run your AI agent on one
        side and monitor progress/state with sidecar on the other.
      '';
      homepage = "https://github.com/marcus/sidecar";
      changelog = "https://github.com/marcus/sidecar/blob/main/CHANGELOG.md";
      license = licenses.mit;
      maintainers = [ ];
      mainProgram = "sidecar";
      platforms = platforms.unix;
    };
  };
}
