# Development Shells

This repository includes specialized development environments using Nix shells. These provide isolated, reproducible environments for specific workflows.

## Available Shells

### default (General Development)

General-purpose development environment for NixOS configuration management.

**Features:**
- Complete Nix toolchain (nixd, nixfmt, deadnix, statix)
- Version control (git, gh)
- Text processing utilities (jq, yq, ripgrep)
- Build tools (make, cmake, pkg-config)
- Shell tools and formatters
- Tree formatting with treefmt

**Usage:**
```bash
nix develop
# or explicitly
nix develop .#default
```

**Helpful Aliases:**
- `nix-fmt` - Format all Nix files recursively
- `nix-check` - Run flake check with trace
- `nix-update` - Update flake inputs
- `rebuild [host]` - Rebuild system configuration
- `build-wsl` - Build WSL tarball

### devshell

Extended general development environment with additional utilities.

**Features:**
- All features from default shell
- Additional development utilities (direnv, tree, btop)
- Network tools (curl, wget, netcat)
- Compression utilities (gzip, bzip2, xz, zip)

**Usage:**
```bash
nix develop .#devshell
```

**Common Commands:**
```bash
nix flake check              # Validate flake configuration
nix flake update             # Update flake inputs
nixfmt **/*.nix    # Format Nix files
deadnix .                    # Find dead Nix code
statix check .               # Lint Nix files
scripts/rebuild.sh [host]    # Rebuild system configuration
```

### claude-flow

Enterprise AI agent orchestration platform development environment.

**Features:**
- Node.js 20 LTS with npm
- Python 3 + C/C++ build toolchain
- TypeScript development tools
- AgentDB vector storage (persists in `.swarm/memory.db`)
- 100+ MCP integrated tools
- 25+ specialized skills
- Multi-agent workflows (2.8-4.4x faster than single-agent)

**Usage:**
```bash
nix develop .#claude-flow

# Install claude-flow (npx method - recommended)
npx claude-flow@alpha init --force
npx claude-flow@alpha --help

# Or clone and develop locally
git clone https://github.com/ruvnet/claude-flow
cd claude-flow
nix develop /path/to/moshpitcodes.nix#claude-flow
npm install
npm run dev
```

**Data Persistence:**
- AgentDB data stored in: `.swarm/memory.db`
- Persists across shell sessions and reboots
- Automatically excluded from git
- 96x-164x faster vector search

**Optional Configuration:**
```bash
# For enhanced embeddings (optional)
export OPENAI_API_KEY="sk-..."
```

**Repository:** https://github.com/ruvnet/claude-flow

## Adding New Shells

To add a new development shell:

1. Create a new file in `shells/your-shell.nix`
2. Add it to `flake.nix` in the `devShells` section:
   ```nix
   devShells.${system} = {
     default = ...;
     your-shell = import ./shells/your-shell.nix { inherit pkgs; };
   };
   ```
3. Document it in this file
4. Test with: `nix develop .#your-shell`
