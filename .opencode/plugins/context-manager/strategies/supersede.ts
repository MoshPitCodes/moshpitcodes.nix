/**
 * Supersede writes strategy - removes write outputs that have been superseded by later reads
 * When a file is written and then later re-read, the write output is redundant
 */

import type { Part, ToolPart, Message } from "@opencode-ai/sdk"
import type { ICMConfig, SessionState, PruneResult } from "../config.js"
import { isProtectedTool, isTurnProtected } from "../config.js"
import { estimateTokens } from "../utils/tokens.js"
import { extractFilePath, isFileReadTool, isFileWriteTool, isProtectedFile } from "../utils/file-patterns.js"
import { basename } from "path"

/**
 * Find write outputs that have been superseded by a subsequent read of the same file
 */
export function findSupersededWrites(
  messages: { info: Message; parts: Part[] }[],
  state: SessionState,
  config: ICMConfig,
): PruneResult[] {
  if (!config.strategies.supersedeWrites.enabled) return []
  const results: PruneResult[] = []

  // Track read positions by file
  const latestReads = new Map<string, number>() // filePath -> message index

  // First pass: find latest read for each file
  for (let mi = 0; mi < messages.length; mi++) {
    for (const part of messages[mi].parts) {
      if (part.type !== "tool") continue
      const tp = part as ToolPart
      if (tp.state.status !== "completed") continue
      if (!isFileReadTool(tp.tool)) continue
      const fp = extractFilePath(tp.tool, tp.state.input)
      if (fp) latestReads.set(fp, mi)
    }
  }

  // Second pass: find writes that precede reads of the same file
  for (let mi = 0; mi < messages.length; mi++) {
    for (const part of messages[mi].parts) {
      if (part.type !== "tool") continue
      const tp = part as ToolPart
      if (tp.state.status !== "completed") continue
      if (!isFileWriteTool(tp.tool)) continue
      if (isProtectedTool(tp.tool, config)) continue
      if (state.prunedIds.has(tp.id)) continue

      const fp = extractFilePath(tp.tool, tp.state.input)
      if (!fp) continue
      if (isProtectedFile(fp, config.protectedFilePatterns)) continue

      const readIdx = latestReads.get(fp)
      if (readIdx !== undefined && readIdx > mi) {
        const tokens = estimateTokens(tp.state.output)
        if (!isTurnProtected(mi, state.turnCount, config)) {
          results.push({
            partId: tp.id,
            toolName: tp.tool,
            reason: `File ${basename(fp)} was subsequently re-read`,
            tokensSaved: tokens,
            strategy: "supersede",
          })
        }
      }
    }
  }

  return results
}
