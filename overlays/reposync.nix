{ inputs }:
final: prev: {
  reposync = prev.buildGoModule rec {
    pname = "reposync";
    version = "1.0.0";

    src = inputs.reposync;

    # Go module vendoring hash
    # Computed from go.mod and go.sum
    vendorHash = "sha256-OMmNgun7bbutlfs3g5zXfykDQUIA8TAfaVhYfprtK2w=";

    # Build the main reposync binary
    subPackages = [ "." ];

    # Build flags - set version info
    ldflags = [
      "-s"
      "-w"
      "-X main.Version=${version}"
    ];

    # CGO is not required for reposync
    env.CGO_ENABLED = "0";

    meta = with prev.lib; {
      description = "Modern Go CLI for interactive repository synchronization from GitHub and local directories";
      longDescription = ''
        Reposync is a modern Go CLI application that simplifies repository management
        by providing an interactive terminal user interface (TUI) for synchronizing
        repositories from GitHub and local directories.

        Features:
        - Interactive TUI with tabs, search, sorting, and real-time progress tracking
        - Batch mode for automation in scripts and CI/CD workflows
        - GitHub integration via gh CLI
        - Local filesystem scanning for Git repositories
        - Persistent configuration at ~/.config/reposync/config.json

        Built with Bubble Tea framework and Lipgloss for a rich terminal experience.
      '';
      homepage = "https://github.com/MoshPitCodes/reposync";
      license = licenses.mit;
      maintainers = [ ];
      mainProgram = "reposync";
      platforms = platforms.unix;
    };
  };
}
