/**
 * Configuration types and defaults for context manager plugin
 */

// ============================================================================
// TYPES & INTERFACES
// ============================================================================

/** Configuration for the ICM plugin */
export interface ICMConfig {
  enabled: boolean
  debug: boolean
  /** Notification level: "off", "minimal", "detailed" */
  pruneNotification: "off" | "minimal" | "detailed"
  /** Where to display notifications */
  pruneNotificationType: "chat" | "toast"
  /** Slash commands configuration */
  commands: {
    enabled: boolean
    protectedTools: string[]
  }
  /** Manual mode: disables autonomous context management */
  manualMode: {
    enabled: boolean
    automaticStrategies: boolean
  }
  /** Turn-based protection for recent tool outputs */
  turnProtection: {
    enabled: boolean
    turns: number
  }
  /** Glob patterns for files protected from pruning */
  protectedFilePatterns: string[]
  /** LLM-driven tool configuration */
  tools: {
    settings: {
      nudgeEnabled: boolean
      nudgeFrequency: number
      /** Token threshold that triggers compress nudge */
      contextLimit: number | string
      /** Per-model overrides for context limits */
      modelLimits: Record<string, number | string>
      protectedTools: string[]
    }
    distill: { permission: "ask" | "allow" | "deny"; showDistillation: boolean }
    compress: { permission: "ask" | "allow" | "deny"; showCompression: boolean }
    prune: { permission: "ask" | "allow" | "deny" }
  }
  /** Automatic pruning strategies */
  strategies: {
    deduplication: {
      enabled: boolean
      /** Similarity threshold for fuzzy matching (0-1) */
      fuzzyThreshold: number
      protectedTools: string[]
    }
    supersedeWrites: { enabled: boolean }
    purgeErrors: {
      enabled: boolean
      turns: number
      protectedTools: string[]
    }
    /** Intelligent compression: replace large outputs with structural summaries */
    smartCompression: {
      enabled: boolean
      /** Minimum output length (chars) before compression kicks in */
      minLength: number
      /** Keep structural metadata (function signatures, exports) */
      preserveStructure: boolean
    }
  }
  /** Semantic analysis settings */
  semantic: {
    enabled: boolean
    /** Track which content references which */
    trackDependencies: boolean
    /** Score decay rate per turn (0-1) */
    decayRate: number
    /** Minimum importance score to keep (0-100) */
    minImportanceToKeep: number
  }
  /** Session memory for cross-session learning */
  memory: {
    enabled: boolean
    persistPath: string
    learnPrunePatterns: boolean
  }
  /** Cache-aware pruning to minimize cache invalidation */
  cacheAwareness: {
    enabled: boolean
    provider: "auto" | "anthropic" | "openai" | "none"
    /** Only prune when net token savings exceeds this threshold */
    minNetSavings: number
  }
}

/** Content importance scoring */
export interface ContentScore {
  /** Importance score 0-100 */
  score: number
  /** What category this content belongs to */
  category: "definition" | "decision" | "output" | "error" | "navigation" | "routine"
  /** Whether content is referenced by later content */
  hasForwardReferences: boolean
  /** Turn number when this content was created */
  turn: number
  /** Number of times this content has been referenced */
  referenceCount: number
}

/** Dependency graph node */
export interface DependencyNode {
  /** Unique ID (part ID or message ID) */
  id: string
  /** Content type */
  type: "tool" | "text" | "file-read" | "file-write" | "file-edit" | "command"
  /** Tool name if applicable */
  toolName?: string
  /** File path if applicable */
  filePath?: string
  /** IDs of nodes this depends on */
  dependsOn: Set<string>
  /** IDs of nodes that depend on this */
  dependedBy: Set<string>
  /** Turn number */
  turn: number
  /** Content length in characters */
  contentLength: number
  /** Estimated token count */
  estimatedTokens: number
  /** Whether this node has been pruned */
  pruned: boolean
  /** Importance score */
  importance: ContentScore
}

/** Session state tracking */
export interface SessionState {
  /** Current turn counter */
  turnCount: number
  /** Variant string for message identification */
  variant?: string
  /** Map of tool call IDs to their metadata */
  toolCalls: Map<string, {
    tool: string
    args: Record<string, unknown>
    output?: string
    error?: string
    turn: number
    partId?: string
    filePath?: string
  }>
  /** Dependency graph */
  dependencies: Map<string, DependencyNode>
  /** Set of pruned part/message IDs */
  prunedIds: Set<string>
  /** Running statistics */
  stats: {
    totalTokensSaved: number
    pruneCount: number
    deduplicationCount: number
    supersedeCount: number
    errorPurgeCount: number
    smartCompressionCount: number
    distillCount: number
    compressCount: number
    nudgesSent: number
    sessionStart: number
  }
  /** File access history: filePath -> { reads: turn[], writes: turn[] } */
  fileHistory: Map<string, { reads: number[]; writes: number[]; edits: number[] }>
  /** Whether manual mode is currently active */
  manualMode: boolean
  /** Detected provider for cache-awareness */
  detectedProvider?: string
  /** Current model info */
  currentModel?: { providerID: string; modelID: string; contextLimit: number }
  /** Tool result count since last nudge */
  toolResultsSinceNudge: number
  /** Session ID */
  sessionId?: string
}

/** Pruning result for a single item */
export interface PruneResult {
  partId: string
  toolName: string
  reason: string
  tokensSaved: number
  strategy: "deduplication" | "supersede" | "error-purge" | "smart-compression" | "manual" | "distill" | "compress" | "prune"
}

// ============================================================================
// CONSTANTS
// ============================================================================

export const PLUGIN_NAME = "icm"
export const PLUGIN_VERSION = "1.0.0"

/** Placeholder text for pruned content */
export const PRUNE_PLACEHOLDER = "[Content pruned by ICM - context optimization]"
export const DEDUP_PLACEHOLDER = "[Duplicate content removed - see latest instance]"
export const SUPERSEDE_PLACEHOLDER = "[Superseded by later file read - current state captured]"
export const ERROR_PURGE_PLACEHOLDER = "[Error input pruned after resolution]"
export const COMPRESS_PLACEHOLDER = "[Compressed by ICM]"

/** Tools that should never be pruned */
export const DEFAULT_PROTECTED_TOOLS = new Set([
  "task",
  "todowrite",
  "todoread",
  "distill",
  "compress",
  "prune",
  "batch",
  "plan_enter",
  "plan_exit",
  "icm_distill",
  "icm_compress",
  "icm_prune",
])

/** Default configuration */
export const DEFAULT_CONFIG: ICMConfig = {
  enabled: true,
  debug: false,
  pruneNotification: "detailed",
  pruneNotificationType: "chat",
  commands: {
    enabled: true,
    protectedTools: [],
  },
  manualMode: {
    enabled: false,
    automaticStrategies: true,
  },
  turnProtection: {
    enabled: false,
    turns: 4,
  },
  protectedFilePatterns: [],
  tools: {
    settings: {
      nudgeEnabled: true,
      nudgeFrequency: 10,
      contextLimit: 100000,
      modelLimits: {},
      protectedTools: [],
    },
    distill: { permission: "allow", showDistillation: false },
    compress: { permission: "deny", showCompression: false },
    prune: { permission: "allow", showDistillation: false } as any,
  },
  strategies: {
    deduplication: {
      enabled: true,
      fuzzyThreshold: 0.92,
      protectedTools: [],
    },
    supersedeWrites: { enabled: true },
    purgeErrors: {
      enabled: true,
      turns: 4,
      protectedTools: [],
    },
    smartCompression: {
      enabled: true,
      minLength: 2000,
      preserveStructure: true,
    },
  },
  semantic: {
    enabled: true,
    trackDependencies: true,
    decayRate: 0.05,
    minImportanceToKeep: 20,
  },
  memory: {
    enabled: true,
    persistPath: ".opencode/data/icm",
    learnPrunePatterns: true,
  },
  cacheAwareness: {
    enabled: true,
    provider: "auto",
    minNetSavings: 500,
  },
}

// ============================================================================
// UTILITY FUNCTIONS FOR CONFIG
// ============================================================================

/**
 * Resolve context limit from config based on model information
 * @param config - ICM configuration
 * @param model - Optional model information
 * @returns Resolved context limit in tokens
 */
export function resolveContextLimit(
  config: ICMConfig,
  model?: { providerID: string; modelID: string; contextLimit: number },
): number {
  if (!model) {
    return typeof config.tools.settings.contextLimit === "number"
      ? config.tools.settings.contextLimit
      : 100000
  }

  const modelKey = `${model.providerID}/${model.modelID}`
  const modelLimit = config.tools.settings.modelLimits[modelKey]
  const limit = modelLimit ?? config.tools.settings.contextLimit

  // Handle percentage-based limits (e.g., "80%")
  if (typeof limit === "string" && limit.endsWith("%")) {
    const pct = parseFloat(limit) / 100
    return Math.floor(model.contextLimit * pct)
  }
  
  return typeof limit === "number" ? limit : 100000
}

/**
 * Check if a tool is protected from pruning
 * @param toolName - Name of the tool to check
 * @param config - ICM configuration
 * @returns True if the tool is protected
 */
export function isProtectedTool(toolName: string, config: ICMConfig): boolean {
  if (DEFAULT_PROTECTED_TOOLS.has(toolName)) return true
  if (config.tools.settings.protectedTools.includes(toolName)) return true
  if (config.commands.protectedTools.includes(toolName)) return true
  return false
}

/**
 * Check if a tool output is protected by turn-based protection
 * @param toolTurn - Turn when tool was executed
 * @param currentTurn - Current turn number
 * @param config - ICM configuration
 * @returns True if the tool output is protected
 */
export function isTurnProtected(toolTurn: number, currentTurn: number, config: ICMConfig): boolean {
  if (!config.turnProtection.enabled) return false
  return currentTurn - toolTurn <= config.turnProtection.turns
}
