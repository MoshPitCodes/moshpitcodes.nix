{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  name = "claude-flow-dev";

  buildInputs = with pkgs; [
    # Node.js runtime (LTS version 20)
    nodejs_24

    # Python for native module compilation (better-sqlite3, node-pty)
    python3

    # C/C++ build chain for native modules
    gcc
    gnumake
    pkg-config

    # Node.js native module builder
    nodePackages.node-gyp

    # Development tools
    git
    typescript
    # nodePackages.ts-node

    # Utilities
    jq # JSON processing
    yq # YAML processing
    curl # For downloading packages/assets
  ];

  shellHook = ''
    echo "╭─────────────────────────────────────────────────────────────────╮"
    echo "│                                                                 │"
    echo "│  🚀 Claude Flow Development Environment                         │"
    echo "│                                                                 │"
    echo "│  Enterprise AI Agent Orchestration Platform                     │"
    echo "│                                                                 │"
    echo "╰─────────────────────────────────────────────────────────────────╯"
    echo ""
    echo "📦 Environment Details:"
    echo "   Node.js: $(node --version)"
    echo "   npm:     $(npm --version)"
    echo "   Python:  $(python3 --version | cut -d' ' -f2)"
    echo ""
    echo "🛠️  Available Commands:"
    echo "   npx claude-flow@alpha init --force  # Initialize claude-flow"
    echo "   npx claude-flow@alpha --help        # Show help"
    echo "   npm install                         # Install dependencies"
    echo "   npm run dev                         # Development mode"
    echo "   npm run build                       # Build project"
    echo "   npm test                            # Run tests"
    echo ""
    echo "📚 Claude Flow Features:"
    echo "   • Multi-agent orchestration (2.8-4.4x faster)"
    echo "   • AgentDB vector storage (.swarm/memory.db)"
    echo "   • 100+ MCP integrated tools"
    echo "   • 25+ specialized skills"
    echo "   • Persistent hybrid memory system"
    echo ""
    echo "💾 Data Persistence:"
    echo "   AgentDB data stored in: .swarm/memory.db"
    echo "   ✓ Persists across shell sessions"
    echo "   ✓ Survives reboots and garbage collection"
    echo ""
    echo "🔧 Optional Configuration:"
    echo "   export OPENAI_API_KEY=\"sk-...\"  # For enhanced embeddings"
    echo ""
    echo "📖 Documentation: https://github.com/ruvnet/claude-flow"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Add node_modules/.bin to PATH if it exists
    if [ -d "node_modules/.bin" ]; then
      export PATH="$PWD/node_modules/.bin:$PATH"
    fi

    # Set up environment for native module compilation
    export PYTHON="${pkgs.python3}/bin/python3"
    export npm_config_build_from_source=true

    # Helpful aliases
    alias cf="npx claude-flow@alpha"
    alias cf-help="npx claude-flow@alpha --help"
    alias cf-init="npx claude-flow@alpha init --force"
  '';

  # Environment variables
  NIX_SHELL_NAME = "claude-flow";

  # Ensure node-gyp can find Python
  PYTHON = "${pkgs.python3}/bin/python3";
}
