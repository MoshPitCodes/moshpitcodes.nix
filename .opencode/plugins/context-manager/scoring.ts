/**
 * Semantic scoring and dependency graph management
 */

import type { ICMConfig, ContentScore, DependencyNode, SessionState } from "./config.js"
import { estimateTokens } from "./utils/tokens.js"
import { extractFilePath, isFileReadTool, isFileWriteTool } from "./utils/file-patterns.js"

/**
 * Score content importance based on tool type, output, age, and category
 */
export function scoreContent(
  toolName: string,
  args: Record<string, unknown>,
  output: string | undefined,
  error: string | undefined,
  turn: number,
  currentTurn: number,
  config: ICMConfig,
): ContentScore {
  let score = 50 // Base score
  let category: ContentScore["category"] = "routine"

  // Category detection
  if (error) {
    category = "error"
    score = 30
  } else if (isFileWriteTool(toolName)) {
    category = "definition"
    score = 70
  } else if (isFileReadTool(toolName)) {
    category = "navigation"
    score = 40
  } else if (toolName === "bash") {
    const cmd = String(args.command ?? "")
    if (cmd.match(/^(npm|bun|yarn)\s+(test|run|build)/)) {
      category = "output"
      score = 55
    } else if (cmd.match(/^(git|docker|kubectl)/)) {
      category = "routine"
      score = 35
    } else {
      category = "output"
      score = 45
    }
  } else if (toolName === "task") {
    category = "decision"
    score = 80
  } else if (toolName === "todowrite" || toolName === "todoread") {
    category = "decision"
    score = 85
  }

  // Output size penalty: very large outputs are less likely to be entirely relevant
  if (output && output.length > 5000) {
    score -= Math.min(15, Math.floor(output.length / 5000))
  }

  // Decay based on age
  const age = currentTurn - turn
  const decay = config.semantic.decayRate * age
  score = Math.max(0, score - Math.floor(decay * 100))

  return {
    score,
    category,
    hasForwardReferences: false,
    turn,
    referenceCount: 0,
  }
}

/**
 * Add a dependency node to the session state's dependency graph
 */
export function addDependencyNode(
  state: SessionState,
  id: string,
  toolName: string,
  args: Record<string, unknown>,
  output: string | undefined,
  turn: number,
  config: ICMConfig,
): void {
  const filePath = extractFilePath(toolName, args)
  const contentLength = (output ?? "").length + JSON.stringify(args).length
  const type = isFileReadTool(toolName) ? "file-read"
    : isFileWriteTool(toolName) ? "file-write"
    : toolName === "bash" ? "command"
    : "tool"

  const importance = scoreContent(toolName, args, output, undefined, turn, state.turnCount, config)

  const node: DependencyNode = {
    id,
    type,
    toolName,
    filePath,
    dependsOn: new Set(),
    dependedBy: new Set(),
    turn,
    contentLength,
    estimatedTokens: estimateTokens(output ?? ""),
    pruned: false,
    importance,
  }

  // Build dependency edges based on file relationships
  if (filePath && config.semantic.trackDependencies) {
    for (const [existingId, existingNode] of state.dependencies) {
      if (existingNode.filePath === filePath && existingId !== id) {
        // If we're reading a file that was previously written, we depend on that write
        if (isFileReadTool(toolName) && (existingNode.type === "file-write" || existingNode.type === "file-edit")) {
          node.dependsOn.add(existingId)
          existingNode.dependedBy.add(id)
        }
        // If we're writing a file that was previously read, mark the read as referenced
        if (isFileWriteTool(toolName) && existingNode.type === "file-read") {
          node.dependsOn.add(existingId)
          existingNode.dependedBy.add(id)
          existingNode.importance.hasForwardReferences = true
          existingNode.importance.referenceCount++
        }
      }
    }
  }

  state.dependencies.set(id, node)
}

/**
 * Check if a node in the dependency graph can be safely pruned
 * (i.e., no non-pruned nodes depend on it)
 */
export function canSafelyPrune(id: string, state: SessionState): boolean {
  const node = state.dependencies.get(id)
  if (!node) return true

  // Don't prune if other non-pruned nodes depend on this
  for (const depId of node.dependedBy) {
    const dep = state.dependencies.get(depId)
    if (dep && !dep.pruned) return false
  }
  return true
}
