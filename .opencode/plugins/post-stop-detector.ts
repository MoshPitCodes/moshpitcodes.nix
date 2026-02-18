import type { Plugin } from "@opencode-ai/plugin"
import {
  writeFile,
  mkdir,
  readdir,
  stat,
  readFile,
  appendFile,
} from "fs/promises"
import { join, relative } from "path"
import { createHash } from "crypto"

interface FileSnapshot {
  path: string
  hash: string
  size: number
  mtime: number
}

interface SessionSnapshot {
  sessionId: string
  timestamp: string
  files: FileSnapshot[]
}

/**
 * Post-Stop Detector Plugin
 *
 * Detects files created after session completion:
 * - Captures filesystem snapshot when session goes idle
 * - Monitors for 30 seconds post-session
 * - Detects orphaned changes (new/modified/deleted files)
 */
export const PostStopDetectorPlugin: Plugin = async ({
  directory,
  client,
}) => {
  const logDir = join(directory, ".opencode", "logs")
  const dataDir = join(directory, ".opencode", "data", "sessions")
  const logFile = join(logDir, "post_stop.jsonl")

  await mkdir(logDir, { recursive: true })
  await mkdir(dataDir, { recursive: true })

  const logEvent = async (data: Record<string, unknown>) => {
    try {
      await client.app.log({
        body: {
          service: "post-stop-detector",
          level: "info",
          message: String(data.event ?? "post_stop"),
          extra: data,
        },
      })
      const entry = { timestamp: new Date().toISOString(), ...data }
      await appendFile(logFile, JSON.stringify(entry) + "\n")
    } catch {
      // Fail silently
    }
  }

  const SKIP_DIRS = new Set([
    "node_modules",
    ".git",
    "dist",
    "build",
    ".next",
  ])
  const SKIP_PREFIXES = [".opencode/data", ".opencode/logs"]
  const MAX_FILE_SIZE = 10 * 1024 * 1024 // 10MB

  async function captureSnapshot(
    root: string,
    sessionId: string,
  ): Promise<SessionSnapshot> {
    const files: FileSnapshot[] = []
    let skippedCount = 0

    async function walk(dir: string) {
      let entries
      try {
        entries = await readdir(dir, { withFileTypes: true })
      } catch {
        return
      }

      for (const entry of entries) {
        if (SKIP_DIRS.has(entry.name)) continue
        const fullPath = join(dir, entry.name)
        const rel = relative(root, fullPath)
        if (SKIP_PREFIXES.some((p) => rel.startsWith(p))) continue

        if (entry.isDirectory()) {
          await walk(fullPath)
        } else if (entry.isFile()) {
          try {
            const stats = await stat(fullPath)
            
            // Skip large files for performance
            if (stats.size > MAX_FILE_SIZE) {
              skippedCount++
              continue
            }
            
            const content = await readFile(fullPath)
            files.push({
              path: rel,
              hash: createHash("sha256").update(content).digest("hex"),
              size: stats.size,
              mtime: stats.mtimeMs,
            })
          } catch {
            // Skip files we can't read
          }
        }
      }
    }

    await walk(root)
    
    // Log skipped files
    if (skippedCount > 0) {
      await logEvent({
        event: "snapshot_skipped_large_files",
        sessionId,
        skippedCount,
        reason: `Files > ${MAX_FILE_SIZE / 1024 / 1024}MB`,
      })
    }
    
    return { sessionId, timestamp: new Date().toISOString(), files }
  }

  async function detectChanges(
    root: string,
    sessionId: string,
    previous: SessionSnapshot,
  ) {
    const current = await captureSnapshot(root, sessionId)

    const previousMap = new Map(previous.files.map((f) => [f.path, f]))
    const currentMap = new Map(current.files.map((f) => [f.path, f]))

    const newFiles: string[] = []
    const modifiedFiles: string[] = []
    const deletedFiles: string[] = []

    for (const [filepath, cur] of currentMap) {
      const prev = previousMap.get(filepath)
      if (!prev) {
        newFiles.push(filepath)
      } else if (prev.hash !== cur.hash) {
        modifiedFiles.push(filepath)
      }
    }

    for (const filepath of previousMap.keys()) {
      if (!currentMap.has(filepath)) {
        deletedFiles.push(filepath)
      }
    }

    const orphanedChanges =
      newFiles.length > 0 ||
      modifiedFiles.length > 0 ||
      deletedFiles.length > 0

    await logEvent({
      event: "post_stop_detection",
      sessionId,
      monitorDuration: "30s",
      orphanedChanges,
      summary: {
        newFiles: newFiles.length,
        modifiedFiles: modifiedFiles.length,
        deletedFiles: deletedFiles.length,
      },
      details: {
        newFiles: newFiles.slice(0, 20),
        modifiedFiles: modifiedFiles.slice(0, 20),
        deletedFiles: deletedFiles.slice(0, 20),
      },
    })
  }

  return {
    event: async ({ event }) => {
      if (event.type !== "session.idle") return

      try {
        const sessionId = event.properties.sessionID

        const snapshot = await captureSnapshot(directory, sessionId)
        const snapshotPath = join(dataDir, `${sessionId}-snapshot.json`)

        await writeFile(snapshotPath, JSON.stringify(snapshot, null, 2))

        await logEvent({
          event: "snapshot_captured",
          sessionId,
          fileCount: snapshot.files.length,
          snapshotPath,
        })

        // Monitor for 30 seconds post-session
        setTimeout(() => {
          void detectChanges(directory, sessionId, snapshot).catch(
            async (error) => {
              await logEvent({
                event: "post_stop_detection_error",
                sessionId,
                error: String(error),
              })
            },
          )
        }, 30_000)
      } catch (error) {
        await logEvent({
          event: "snapshot_error",
          error: String(error),
        })
      }
    },
  }
}

export default PostStopDetectorPlugin
