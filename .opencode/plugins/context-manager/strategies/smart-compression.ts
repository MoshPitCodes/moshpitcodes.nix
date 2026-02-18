/**
 * Smart compression strategy - replaces large tool outputs with structural summaries
 * Preserves key structural information (function signatures, exports, headings)
 * while freeing significant context space
 */

import type { Part, ToolPart, Message } from "@opencode-ai/sdk"
import type { ICMConfig, SessionState, PruneResult } from "../config.js"
import { isProtectedTool, isTurnProtected } from "../config.js"
import { estimateTokens } from "../utils/tokens.js"
import { extractFilePath, isProtectedFile } from "../utils/file-patterns.js"
import { scoreContent, canSafelyPrune } from "../scoring.js"
import { basename } from "path"

/**
 * Generate a smart structural summary of tool output
 */
export function generateSmartSummary(toolName: string, output: string, args: Record<string, unknown>): string {
  const lines = output.split("\n")
  const lineCount = lines.length
  const charCount = output.length

  if (toolName === "read" || toolName === "glob") {
    // For file reads, extract key structural info
    const filePath = extractFilePath(toolName, args) ?? "unknown"
    const ext = filePath.split(".").pop()?.toLowerCase()

    if (ext === "ts" || ext === "tsx" || ext === "js" || ext === "jsx") {
      return extractCodeStructure(output, filePath)
    }
    if (ext === "json" || ext === "jsonc") {
      return extractJsonStructure(output, filePath)
    }
    if (ext === "md") {
      return extractMarkdownStructure(output, filePath)
    }

    // Generic summary
    return [
      `[ICM Smart Summary] File: ${basename(filePath)} (${lineCount} lines, ~${estimateTokens(output)} tokens)`,
      `First 10 lines preview:`,
      lines.slice(0, 10).join("\n"),
      `... (${lineCount - 10} more lines)`,
      `[Full content available on re-read]`,
    ].join("\n")
  }

  if (toolName === "bash") {
    const cmd = String(args.command ?? "")
    return [
      `[ICM Smart Summary] Command: ${cmd.substring(0, 100)}`,
      `Output: ${lineCount} lines, ${charCount} chars`,
      `First 5 lines:`,
      lines.slice(0, 5).join("\n"),
      lines.length > 10 ? `Last 5 lines:` : "",
      lines.length > 10 ? lines.slice(-5).join("\n") : "",
      `[Full output pruned - re-run command if needed]`,
    ].filter(Boolean).join("\n")
  }

  // Generic tool output summary
  return [
    `[ICM Smart Summary] Tool: ${toolName} (${charCount} chars, ~${estimateTokens(output)} tokens)`,
    output.substring(0, 500),
    charCount > 500 ? `... (${charCount - 500} chars truncated)` : "",
  ].filter(Boolean).join("\n")
}

/**
 * Extract structural information from TypeScript/JavaScript code
 */
function extractCodeStructure(code: string, filePath: string): string {
  const lines = code.split("\n")
  const imports: string[] = []
  const exports: string[] = []
  const functions: string[] = []
  const classes: string[] = []
  const types: string[] = []

  for (const line of lines) {
    const trimmed = line.trim()
    if (trimmed.startsWith("import ")) imports.push(trimmed)
    if (trimmed.startsWith("export ")) {
      if (trimmed.includes("function ")) {
        const match = trimmed.match(/export\s+(?:default\s+)?(?:async\s+)?function\s+(\w+)/)
        if (match) functions.push(match[0] + "(...)")
      } else if (trimmed.includes("class ")) {
        const match = trimmed.match(/export\s+(?:default\s+)?class\s+(\w+)/)
        if (match) classes.push(match[0])
      } else if (trimmed.includes("type ") || trimmed.includes("interface ")) {
        const match = trimmed.match(/export\s+(?:type|interface)\s+(\w+)/)
        if (match) types.push(match[0])
      } else {
        exports.push(trimmed.substring(0, 80))
      }
    }
    if (!trimmed.startsWith("export") && trimmed.match(/^(?:async\s+)?function\s+(\w+)/)) {
      const match = trimmed.match(/^(?:async\s+)?function\s+(\w+)/)
      if (match) functions.push(match[0] + "(...)")
    }
    if (!trimmed.startsWith("export") && trimmed.match(/^class\s+(\w+)/)) {
      const match = trimmed.match(/^class\s+(\w+)/)
      if (match) classes.push(match[0])
    }
  }

  const parts = [
    `[ICM Smart Summary] File: ${basename(filePath)} (${lines.length} lines, ~${estimateTokens(code)} tokens)`,
  ]
  if (imports.length > 0) parts.push(`Imports (${imports.length}): ${imports.slice(0, 5).join("; ")}${imports.length > 5 ? "..." : ""}`)
  if (types.length > 0) parts.push(`Types: ${types.join(", ")}`)
  if (classes.length > 0) parts.push(`Classes: ${classes.join(", ")}`)
  if (functions.length > 0) parts.push(`Functions: ${functions.join(", ")}`)
  if (exports.length > 0) parts.push(`Exports: ${exports.slice(0, 5).join("; ")}${exports.length > 5 ? "..." : ""}`)
  parts.push(`[Full content available on re-read]`)

  return parts.join("\n")
}

/**
 * Extract structural information from JSON files
 */
function extractJsonStructure(json: string, filePath: string): string {
  try {
    const parsed = JSON.parse(json)
    const keys = Object.keys(parsed)
    return [
      `[ICM Smart Summary] JSON: ${basename(filePath)} (${keys.length} top-level keys)`,
      `Keys: ${keys.slice(0, 20).join(", ")}${keys.length > 20 ? "..." : ""}`,
      `[Full content available on re-read]`,
    ].join("\n")
  } catch {
    return `[ICM Smart Summary] JSON: ${basename(filePath)} (~${estimateTokens(json)} tokens) [parse error - full content available on re-read]`
  }
}

/**
 * Extract structural information from Markdown files
 */
function extractMarkdownStructure(md: string, filePath: string): string {
  const headings: string[] = []
  for (const line of md.split("\n")) {
    if (line.startsWith("#")) headings.push(line.trim())
  }
  return [
    `[ICM Smart Summary] Markdown: ${basename(filePath)} (${md.split("\n").length} lines)`,
    headings.length > 0 ? `Headings: ${headings.slice(0, 10).join(" | ")}${headings.length > 10 ? "..." : ""}` : "",
    `[Full content available on re-read]`,
  ].filter(Boolean).join("\n")
}

/**
 * Find large tool outputs that can be smart-compressed
 */
export function findSmartCompressible(
  messages: { info: Message; parts: Part[] }[],
  state: SessionState,
  config: ICMConfig,
): PruneResult[] {
  if (!config.strategies.smartCompression.enabled) return []
  const results: PruneResult[] = []
  const minLen = config.strategies.smartCompression.minLength

  for (const msg of messages) {
    for (const part of msg.parts) {
      if (part.type !== "tool") continue
      const tp = part as ToolPart
      if (tp.state.status !== "completed") continue
      if (isProtectedTool(tp.tool, config)) continue
      if (state.prunedIds.has(tp.id)) continue

      const output = tp.state.output
      if (!output || output.length < minLen) continue
      if (isTurnProtected(state.turnCount, state.turnCount, config)) continue

      // Check dependency graph: don't compress if content is still referenced
      if (config.semantic.trackDependencies && !canSafelyPrune(tp.id, state)) continue

      const filePath = extractFilePath(tp.tool, tp.state.input)
      if (filePath && isProtectedFile(filePath, config.protectedFilePatterns)) continue

      // Check importance score
      const toolEntry = state.toolCalls.get(tp.callID)
      if (toolEntry) {
        const importance = scoreContent(tp.tool, tp.state.input as Record<string, unknown>, output, undefined, toolEntry.turn, state.turnCount, config)
        if (importance.score >= 60) continue // Still important enough
      }

      const currentTokens = estimateTokens(output)
      const summary = generateSmartSummary(tp.tool, output, tp.state.input as Record<string, unknown>)
      const summaryTokens = estimateTokens(summary)
      const savings = currentTokens - summaryTokens

      if (savings > 100) { // Only worth it if we save meaningful tokens
        results.push({
          partId: tp.id,
          toolName: tp.tool,
          reason: `Smart compression: ${currentTokens} -> ${summaryTokens} tokens`,
          tokensSaved: savings,
          strategy: "smart-compression",
        })
      }
    }
  }

  return results
}
