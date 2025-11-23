# Development Shells

This directory contains Nix development shell configurations for various projects and tools.

## Available Shells

### claude-flow

Enterprise AI agent orchestration platform development environment.

**Features:**
- Node.js 20 LTS with npm
- Python 3 for native module compilation
- C/C++ build toolchain (gcc, make, pkg-config)
- TypeScript development tools
- AgentDB vector storage support
- Persistent data in `.swarm/memory.db`

**Usage:**

```bash
# Enter the development shell
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

**What's Included:**
- Multi-agent orchestration (2.8-4.4x faster workflows)
- 100+ MCP integrated tools
- 25+ specialized skills
- Persistent hybrid memory system
- AgentDB vector database (96x-164x faster search)

**Data Persistence:**
- AgentDB data stored in: `.swarm/memory.db`
- ✅ Persists across shell sessions
- ✅ Survives reboots and garbage collection
- ✅ Automatically excluded from git

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
3. Document it in this README
4. Test with: `nix develop .#your-shell`
