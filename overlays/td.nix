{ inputs }:
final: prev: {
  td = prev.buildGoModule rec {
    pname = "td";
    version = "0.33.0";

    src = inputs.td;

    # Go module vendoring hash
    # Using proxyVendor for proper module vendoring
    proxyVendor = true;
    vendorHash = "sha256-rwb+x4RVYoYfr9UM4x6TWs6Tkvcl7r6bMxGmn0z0FZE=";

    # Build the main td binary
    subPackages = [ "." ];

    # Build flags - set version info
    ldflags = [
      "-s"
      "-w"
      "-X main.Version=${version}"
    ];

    # CGO is required for sqlite
    env.CGO_ENABLED = "1";

    meta = with prev.lib; {
      description = "Task management CLI for AI-assisted development - external memory for AI agents across context windows";
      longDescription = ''
        TD (Task Definition) is a minimalist CLI for tracking tasks across AI
        coding sessions. When your AI agent's context window ends, its memory
        ends—TD is the external memory that lets the next session pick up
        exactly where the last one left off.

        Key Features:
        - Structured handoffs (done/remaining/decisions/uncertain)
        - Session isolation (code writer ≠ code reviewer)
        - Query-based boards with TDQ query language
        - Dependency graphs and critical path finding
        - Epic tracking for large initiatives
        - File tracking with SHA verification
        - Live monitor dashboard (integrates with sidecar)
        - Session analytics and audit logs

        Perfect companion to AI coding agents like Claude Code, Cursor, and
        OpenCode. Integrates with sidecar's TD Monitor plugin for real-time
        task visualization.
      '';
      homepage = "https://github.com/marcus/td";
      changelog = "https://github.com/marcus/td/blob/main/CHANGELOG.md";
      license = licenses.mit;
      maintainers = [ ];
      mainProgram = "td";
      platforms = platforms.unix;
    };
  };
}
