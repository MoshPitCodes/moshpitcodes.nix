# Intelligent Context Manager (ICM) Plugin

A modular OpenCode plugin that automatically manages conversation context size through intelligent pruning strategies.

## Architecture

```
context-manager/
├── index.ts              # Main plugin entry point - hooks, commands, lifecycle
├── config.ts             # Types, interfaces, constants, defaults
├── logger.ts             # Structured JSONL logging (ICMLogger class)
├── state.ts              # Session state management and config loading
├── scoring.ts            # Semantic scoring and dependency graph
├── strategies/
│   ├── index.ts          # Re-exports all strategies
│   ├── deduplication.ts  # Exact and fuzzy duplicate detection
│   ├── supersede.ts      # Superseded write detection
│   ├── error-purge.ts    # Error input purging after resolution
│   └── smart-compression.ts  # Structural summary compression
├── tools/
│   ├── index.ts          # Re-exports all tools
│   ├── distill.ts        # icm_distill - extract findings before pruning
│   ├── compress.ts       # icm_compress - collapse conversation ranges
│   └── prune.ts          # icm_prune - remove unneeded tool outputs
└── utils/
    ├── index.ts          # Re-exports all utilities
    ├── tokens.ts         # Token estimation (chars/token heuristic)
    ├── similarity.ts     # Trigram similarity with LRU caching
    └── file-patterns.ts  # File path extraction and glob matching
```

## Strategies

### Deduplication
Detects and removes duplicate tool outputs. Supports:
- **Exact deduplication**: Same tool + same arguments = keep latest only
- **Fuzzy deduplication**: Trigram-based similarity (configurable threshold, default 0.92)

### Supersede Writes
When a file is written and then later re-read, the write output becomes redundant since the read captures the current state.

### Error Purge
After errors are resolved (configurable turn threshold), the verbose error input is pruned since it's no longer needed for debugging.

### Smart Compression
Replaces large tool outputs with structural summaries preserving:
- TypeScript/JavaScript: imports, exports, functions, classes, types
- JSON: top-level keys
- Markdown: heading structure
- Bash: first/last lines of output
- Generic: truncated preview

## LLM Tools

### `icm_distill`
Extract key findings from tool outputs into a summary, then prune the originals. Preserves important information while freeing context.

### `icm_compress`
Collapse a range of exploratory conversation steps into what was learned. Useful after reading multiple files or running multiple commands.

### `icm_prune`
Remove completed or noisy tool outputs that are no longer needed.

## Configuration

Create `.opencode/icm.json` (or `.jsonc` with comments):

```jsonc
{
  // Master switch
  "enabled": true,
  "debug": false,

  // Notification settings
  "pruneNotification": "detailed",  // "off" | "minimal" | "detailed"

  // Manual mode (disables automatic strategies)
  "manualMode": {
    "enabled": false,
    "automaticStrategies": true
  },

  // Turn-based protection for recent outputs
  "turnProtection": {
    "enabled": false,
    "turns": 4
  },

  // Strategy configuration
  "strategies": {
    "deduplication": {
      "enabled": true,
      "fuzzyThreshold": 0.92
    },
    "supersedeWrites": { "enabled": true },
    "purgeErrors": {
      "enabled": true,
      "turns": 4
    },
    "smartCompression": {
      "enabled": true,
      "minLength": 2000,
      "preserveStructure": true
    }
  },

  // Tool permissions
  "tools": {
    "distill": { "permission": "allow" },
    "compress": { "permission": "deny" },
    "prune": { "permission": "allow" }
  },

  // Context limits (supports percentages like "80%")
  "tools": {
    "settings": {
      "contextLimit": 100000,
      "nudgeEnabled": true,
      "nudgeFrequency": 10
    }
  }
}
```

Config files are loaded in priority order:
1. `~/.config/opencode/icm.json`
2. `$OPENCODE_CONFIG_DIR/icm.json`
3. `<project>/.opencode/icm.json`

Later files override earlier ones (deep merge).

## Slash Commands

- `/icm` - Show help and status
- `/icm stats` - Show pruning statistics
- `/icm context` - Show context token breakdown
- `/icm sweep [N]` - Prune last N tool outputs
- `/icm manual [on|off]` - Toggle manual mode
- `/icm prune [focus]` - Trigger prune with focus area
- `/icm distill [focus]` - Trigger distill with focus area
- `/icm compress [focus]` - Trigger compress with focus area

## Key Features

- **Cache-aware pruning**: Prefers pruning later content to preserve cached prefixes
- **Dependency graph**: Tracks file read/write relationships to avoid pruning referenced content
- **Semantic scoring**: Scores content importance by category, age, and reference count
- **Session memory**: Learns hot files and frequently pruned tools across sessions
- **Protected tools**: Never prunes task, todowrite, todoread, or ICM tools themselves

## Logging

All operations logged to `.opencode/logs/` in JSONL format:
- `icm.jsonl` - General info/warn/error logs
- `icm_debug.jsonl` - Debug-level logs (when `debug: true`)
- `icm_prune.jsonl` - Individual prune operations
- `icm_stats.jsonl` - Session statistics

## Migration from Monolithic File

If upgrading from the single-file `context-manager.ts`:

1. Back up: `cp context-manager.ts context-manager.ts.backup`
2. Replace with this directory structure
3. Verify: `cd .opencode && bunx tsc --noEmit`
4. Clean up: `rm context-manager.ts.backup`

The modular version is functionally identical to the monolithic version.
