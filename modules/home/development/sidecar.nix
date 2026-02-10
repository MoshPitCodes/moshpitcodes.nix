{
  lib,
  pkgs,
  config,
  ...
}:
let
  # Default sidecar configuration
  # Users can override per-project by creating .sidecar/config.json in project root
  defaultConfig = {
    plugins = {
      git-status = {
        enabled = true;
        refreshInterval = "1s";
      };
      td-monitor = {
        enabled = true;
        refreshInterval = "2s";
      };
      conversations = {
        enabled = true;
      };
      file-browser = {
        enabled = true;
      };
      workspaces = {
        enabled = true;
      };
    };
    ui = {
      showClock = true;
      theme = {
        name = "default";
        overrides = { };
      };
    };
    projects = {
      list = [
        {
          name = "nixos";
          path = "~/Development/moshpitcodes.nix";
        }
        # Add more projects as needed
        # { name = "my-project", path = "~/Development/my-project" }
      ];
    };
  };
in
{
  # Install sidecar and td packages
  home.packages = with pkgs; [
    sidecar
    td # Task management for AI-assisted development
  ];

  # Create sidecar configuration directory and config file
  home.file = {
    # Global configuration file
    ".config/sidecar/config.json" = {
      text = builtins.toJSON defaultConfig;
      # Make it writable so users can modify projects list
      onChange = ''
        if [ -L "$HOME/.config/sidecar/config.json" ]; then
          cp -f "$HOME/.config/sidecar/config.json" "$HOME/.config/sidecar/config.json.tmp"
          rm -f "$HOME/.config/sidecar/config.json"
          mv "$HOME/.config/sidecar/config.json.tmp" "$HOME/.config/sidecar/config.json"
          chmod u+w "$HOME/.config/sidecar/config.json"
        fi
      '';
    };
  };

  # Shell aliases and functions for sidecar workflows
  programs.zsh.shellAliases = {
    # Basic sidecar commands
    sc = "sidecar"; # Quick alias
    sidecar-help = "sidecar --help";
    sidecar-version = "sidecar --version";

    # Sidecar with debug logging
    scd = "sidecar --debug";

    # Launch sidecar in specific project
    scp = "sidecar --project";

    # Show sidecar configuration
    sidecar-config = "cat ~/.config/sidecar/config.json | ${pkgs.jq}/bin/jq";

    # Edit sidecar configuration
    sidecar-edit = "\${EDITOR:-nvim} ~/.config/sidecar/config.json";

    # Add current directory to sidecar projects
    sidecar-add-project = ''
      project_name="''${1:-$(basename $(pwd))}"
      project_path="$(pwd)"
      echo "Adding project: $project_name -> $project_path"
      ${pkgs.jq}/bin/jq --arg name "$project_name" --arg path "$project_path" \
        '.projects.list += [{name: $name, path: $path}]' \
        ~/.config/sidecar/config.json > ~/.config/sidecar/config.json.tmp && \
      mv ~/.config/sidecar/config.json.tmp ~/.config/sidecar/config.json
      echo "✓ Project added to sidecar. Press @ in sidecar to switch projects."
    '';

    # === TD (Task Management) Aliases ===
    # Quick access to TD commands
    tdi = "td init"; # Initialize TD in project
    tdc = "td create"; # Create new task
    tds = "td start"; # Start working on task
    tdl = "td list"; # List all tasks
    tdn = "td next"; # What should I work on next?
    tdu = "td usage"; # Current state for AI agents
    tdm = "td monitor"; # Live task monitor
    tdr = "td review"; # Submit task for review
    tda = "td approve"; # Approve reviewed task
    tdh = "td handoff"; # Capture handoff state
    tdq = "td query"; # Query tasks with TDQ
    tdb = "td board"; # Manage boards
  };

  # ZSH functions for advanced workflows
  programs.zsh.initContent = ''
    # Sidecar split-pane workflow helpers
    # These are opinionated recommendations for AI-assisted development

    # Launch AI agent + sidecar in split terminal
    # Usage: sidecar-split [claude|cursor|opencode]
    sidecar-split() {
      local agent="''${1:-claude}"
      
      case "$agent" in
        claude)
          # Split terminal: Claude Code on left, sidecar on right
          echo "🚀 Launching Claude Code + Sidecar split workflow..."
          echo "Left pane: Claude Code | Right pane: Sidecar"
          # Use tmux or your terminal's split functionality
          if command -v tmux &> /dev/null && [ -n "$TMUX" ]; then
            tmux split-window -h -p 35 "sidecar"
            tmux select-pane -L
            claude
          else
            echo "Note: This works best in tmux. Run 'tmux' first, then 'sidecar-split'"
            sidecar
          fi
          ;;
        cursor)
          echo "🚀 Launching Cursor + Sidecar split workflow..."
          if command -v tmux &> /dev/null && [ -n "$TMUX" ]; then
            tmux split-window -h -p 35 "sidecar"
            tmux select-pane -L
            cursor .
          else
            sidecar
          fi
          ;;
        opencode)
          echo "🚀 Launching OpenCode + Sidecar split workflow..."
          if command -v tmux &> /dev/null && [ -n "$TMUX" ]; then
            tmux split-window -h -p 35 "sidecar"
            tmux select-pane -L
            opencode
          else
            sidecar
          fi
          ;;
        *)
          echo "Usage: sidecar-split [claude|cursor|opencode]"
          echo "Launches an AI coding agent with sidecar in split-pane view"
          ;;
      esac
    }

    # Dual sidecar dashboard - two sidecar instances side-by-side
    # One for tasks (TD monitor), one for git status
    sidecar-dashboard() {
      if command -v tmux &> /dev/null && [ -n "$TMUX" ]; then
        echo "🎛️  Launching Sidecar Dashboard (Tasks + Git)..."
        # Left: sidecar on Tasks plugin (plugin #3)
        tmux split-window -h -p 50 "sidecar"
        # Right: sidecar on Git plugin (plugin #1)
        tmux select-pane -R
        echo "Use Tab to navigate between plugins in each pane"
        echo "Plugin 1: Git | Plugin 2: Conversations | Plugin 3: Tasks | Plugin 4: Files | Plugin 5: Workspaces"
      else
        echo "⚠️  This requires tmux. Run 'tmux' first, then 'sidecar-dashboard'"
        sidecar
      fi
    }

    # Quick project switch - fuzzy find projects from config
    sidecar-goto() {
      if ! command -v ${pkgs.jq}/bin/jq &> /dev/null || ! command -v ${pkgs.fzf}/bin/fzf &> /dev/null; then
        echo "⚠️  Requires jq and fzf"
        return 1
      fi
      
      local selected
      selected=$(${pkgs.jq}/bin/jq -r '.projects.list[] | "\(.name)|\(.path)"' ~/.config/sidecar/config.json | \
        ${pkgs.fzf}/bin/fzf --delimiter="|" --with-nth=1 --preview='echo {2}' --preview-window=down:1)
      
      if [ -n "$selected" ]; then
        local project_path=$(echo "$selected" | cut -d'|' -f2)
        # Expand tilde
        project_path="''${project_path/#\~/$HOME}"
        cd "$project_path" && sidecar
      fi
    }

    # Launch sidecar with TD (task management) already linked
    # This is useful when starting work on a new feature
    sidecar-td() {
      if command -v td &> /dev/null; then
        echo "📋 Launching sidecar with TD task management..."
        sidecar
      else
        echo "⚠️  TD (task management) is not installed"
        echo "Install from: https://github.com/marcus/td"
        sidecar
      fi
    }

    # TD workflow helpers for AI-assisted development

    # Initialize TD in current project and add to sidecar
    td-init-project() {
      local project_name="''${1:-$(basename $(pwd))}"
      
      echo "🎯 Initializing TD + Sidecar in project: $project_name"
      
      # Initialize TD
      if [ ! -d .todos ]; then
        td init
        echo "✓ TD initialized in $(pwd)"
      else
        echo "⚠  TD already initialized"
      fi
      
      # Add to sidecar projects
      ${pkgs.jq}/bin/jq --arg name "$project_name" --arg path "$(pwd)" \
        '.projects.list += [{name: $name, path: $path}]' \
        ~/.config/sidecar/config.json > ~/.config/sidecar/config.json.tmp && \
      mv ~/.config/sidecar/config.json.tmp ~/.config/sidecar/config.json
      
      echo "✓ Project added to sidecar"
      echo ""
      echo "Next steps:"
      echo "  1. Create your first task: td create 'My first task'"
      echo "  2. Launch sidecar: sidecar"
      echo "  3. Press Tab to navigate to TD Monitor plugin"
    }

    # Quick AI agent handoff workflow
    td-ai-handoff() {
      if [ -z "$1" ]; then
        echo "Usage: td-ai-handoff <issue-id>"
        echo "Example: td-ai-handoff td-a1b2"
        return 1
      fi
      
      local issue_id="$1"
      echo "📋 Creating AI agent handoff for $issue_id..."
      echo ""
      echo "What's done? (Ctrl+D when finished)"
      local done=$(cat)
      echo ""
      echo "What remains? (Ctrl+D when finished)"
      local remaining=$(cat)
      echo ""
      echo "Any decisions made? (optional, Ctrl+D when finished)"
      local decision=$(cat)
      echo ""
      echo "Anything uncertain? (optional, Ctrl+D when finished)"
      local uncertain=$(cat)
      
      # Build handoff command
      local cmd="td handoff $issue_id --done \"$done\" --remaining \"$remaining\""
      [ -n "$decision" ] && cmd="$cmd --decision \"$decision\""
      [ -n "$uncertain" ] && cmd="$cmd --uncertain \"$uncertain\""
      
      eval "$cmd"
      echo "✓ Handoff captured for $issue_id"
    }

    # Quick start workflow: create + start + link files
    td-quick-start() {
      local title="$1"
      shift
      local files=("$@")
      
      if [ -z "$title" ]; then
        echo "Usage: td-quick-start 'Task title' [file1] [file2] ..."
        echo "Example: td-quick-start 'Add OAuth login' src/auth/*.ts"
        return 1
      fi
      
      # Create and capture ID
      local output=$(td create "$title" --type feature --priority P1)
      local issue_id=$(echo "$output" | grep -o 'td-[a-z0-9]\+' | head -1)
      
      if [ -n "$issue_id" ]; then
        echo "✓ Created: $issue_id"
        
        # Start work
        td start "$issue_id"
        echo "✓ Started work on $issue_id"
        
        # Link files if provided
        if [ ''${#files[@]} -gt 0 ]; then
          td link "$issue_id" "''${files[@]}"
          echo "✓ Linked ''${#files[@]} file(s) to $issue_id"
        fi
        
        echo ""
        echo "Ready to work! Open sidecar to monitor progress."
      else
        echo "⚠  Failed to create task"
      fi
    }

    # View TD stats in formatted output
    td-stats() {
      echo "📊 TD Statistics"
      echo "════════════════════════════════════════"
      td list --status open | head -1
      td list --status in_progress | head -1
      td list --status in_review | head -1
      td list --status closed | tail -5
      echo ""
      echo "📈 Run 'td monitor' for live dashboard"
      echo "🎯 Run 'td usage' for AI agent context"
    }

    # Sidecar workflow tips
    sidecar-tips() {
      cat << 'EOF'
    ╔══════════════════════════════════════════════════════════════════╗
    ║                  Sidecar Workflow Tips                           ║
    ╚══════════════════════════════════════════════════════════════════╝

    🎯 Recommended Setup (Split Terminal):
       ┌─────────────────────────┬───────────────────┐
       │  Claude Code / Cursor   │     Sidecar       │
       │  (AI Agent)             │  (Monitor/Review) │
       └─────────────────────────┴───────────────────┘

    💡 Quick Start:
       1. Run 'tmux' to start a multiplexer session
       2. Run 'sidecar-split claude' for AI + monitoring
       3. Or 'sidecar-dashboard' for dual sidecar view

    ⌨️  Essential Shortcuts:
       @         - Switch between projects (fast!)
       W         - Switch git worktrees
       #         - Theme switcher (453 community themes!)
       Tab       - Navigate between plugins
       1-5       - Jump to plugin by number
       ?         - Toggle help

    📦 Plugins:
       1. Git Status    - Stage/unstage, view diffs, commits
       2. Conversations - AI agent session history
       3. TD Monitor    - Task tracking for AI workflows (requires 'td' CLI)
       4. Files         - Project file browser
       5. Workspaces    - Parallel dev with branches

    🔧 Sidecar Commands:
       sc                  - Launch sidecar (quick alias)
       sidecar-split       - AI agent + sidecar split
       sidecar-dashboard   - Dual sidecar monitoring
       sidecar-goto        - Fuzzy search projects
       sidecar-add-project - Add current dir to projects
       sidecar-config      - View configuration
       sidecar-edit        - Edit configuration

    📋 TD Task Management:
       tdi / td init       - Initialize TD in project
       tdc / td create     - Create new task
       tds / td start      - Start working on task
       tdu / td usage      - Show state for AI agents
       tdm / td monitor    - Live task dashboard
       td-init-project     - Init TD + add to sidecar
       td-quick-start      - Create + start + link files
       td-ai-handoff       - Interactive handoff workflow
       td-stats            - View task statistics

    🎨 Themes:
       - Press # in sidecar to browse 453 community themes
       - Live preview as you navigate
       - Derived from iTerm2-Color-Schemes

    🔗 Integration:
       - Works with Claude Code, Cursor, OpenCode, Gemini CLI
       - Conversations plugin tracks all AI sessions
       - Git plugin auto-refreshes on file changes

    📚 Documentation:
       https://marcus.github.io/sidecar/
    EOF
    }
  '';

  # Bash equivalents (simpler versions)
  programs.bash.shellAliases = {
    sc = "sidecar";
    scd = "sidecar --debug";
    scp = "sidecar --project";
    sidecar-help = "sidecar --help";
    sidecar-config = "cat ~/.config/sidecar/config.json | ${pkgs.jq}/bin/jq";
    sidecar-edit = "\${EDITOR:-nvim} ~/.config/sidecar/config.json";
  };

  programs.bash.initExtra = ''
    # Simplified sidecar tips for bash
    sidecar-tips() {
      echo "Sidecar Workflow Tips:"
      echo "  sc              - Launch sidecar"
      echo "  scd             - Launch with debug mode"
      echo "  @               - Switch projects (in sidecar)"
      echo "  #               - Browse themes (in sidecar)"
      echo "  sidecar-config  - View configuration"
      echo ""
      echo "Recommended: Run in tmux split with your AI agent"
      echo "Documentation: https://marcus.github.io/sidecar/"
    }
  '';
}
