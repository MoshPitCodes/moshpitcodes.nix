/**
 * File path pattern matching and utilities
 */

/**
 * Extract file path from tool arguments
 * @param toolName - Name of the tool
 * @param args - Tool arguments
 * @returns Extracted file path or undefined
 */
export function extractFilePath(toolName: string, args: Record<string, unknown>): string | undefined {
  if (args.filePath && typeof args.filePath === "string") return args.filePath
  if (args.file && typeof args.file === "string") return args.file
  if (args.path && typeof args.path === "string") return args.path
  
  // Try to extract file paths from bash commands (rough heuristic)
  if (toolName === "bash" && typeof args.command === "string") {
    const match = args.command.match(/(?:cat|head|tail|less|more|vim|nano|code)\s+["']?([^\s"'|>]+)/)
    return match?.[1]
  }
  
  return undefined
}

/**
 * Check if a tool is a file reading tool
 * @param toolName - Name of the tool to check
 * @returns True if the tool reads files
 */
export function isFileReadTool(toolName: string): boolean {
  return ["read", "glob", "grep"].includes(toolName)
}

/**
 * Check if a tool is a file writing tool
 * @param toolName - Name of the tool to check
 * @returns True if the tool writes files
 */
export function isFileWriteTool(toolName: string): boolean {
  return ["write", "edit"].includes(toolName)
}

/**
 * Check if a file path matches any protected pattern
 * @param filePath - The file path to check
 * @param patterns - Array of glob patterns to match against
 * @returns True if the file path matches any protected pattern
 */
export function isProtectedFile(filePath: string, patterns: string[]): boolean {
  if (!filePath || patterns.length === 0) return false
  
  for (const pattern of patterns) {
    if (simpleGlobMatch(pattern, filePath)) return true
  }
  
  return false
}

/**
 * Very simple glob matching (supports * and **)
 * @param pattern - Glob pattern (e.g., "*.ts", "src/**\/test.js")
 * @param path - Path to test against pattern
 * @returns True if path matches pattern
 */
export function simpleGlobMatch(pattern: string, path: string): boolean {
  const regex = pattern
    .replace(/\*\*/g, "___GLOBSTAR___")
    .replace(/\*/g, "[^/]*")
    .replace(/___GLOBSTAR___/g, ".*")
    .replace(/\?/g, ".")
  
  return new RegExp(`^${regex}$`).test(path)
}
