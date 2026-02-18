Plan: Adopt template-claude into template-opencode (full parity, no status line)
 Task Description
We have a sibling repo (`~/Development/template-claude`) derived from our OpenCode template but adapted for Claude Code. It includes extra slash commands and Python hook automation (session context injection, tool failure context, transcript backups, idle detection, permission auditing, subagent tracking) plus a more TD-forward “plan → build” workflow. We want to adopt those improvements into `template-opencode` using OpenCode-native implementations (TypeScript plugins + OpenCode command conventions), targeting parity of outcomes, not a literal copy of Claude hook mechanics.
 Objective
Achieve functional parity with template-claude across:
- Slash commands: plan/build/git_status/question/plan_w_team (+ keep task-with-td)
- Plan format: include explicit `## TD Tasks` mapping to implementation steps
- Session automation behaviors: session start context, tool failure context, prompt auditing, transcript-equivalent backups, idle/incomplete-work reminders, permission auditing, subagent tracking
- TD workflow integration end-to-end (planning + delegation + build)
Explicitly out of scope:
- Status line features, scripts, and commands (`statusLine`, `.claude/status_lines`, `/update_status_line`)
 Solution Approach
1. Inventory deltas and define parity targets (what “same outcome” means in OpenCode).
2. Port user-facing workflows first (commands + plan format).
3. Implement a “Claude-hooks parity layer” using OpenCode plugins:
   - reuse/extend existing plugins where possible (security/logging/notifications/post-stop/td-enforcer/context-manager)
   - add new focused plugins only when there is no clean fit
4. Validate with smoke tests in a fresh session, plus typechecking `.opencode` TypeScript.
 Relevant Files
Source (Claude):
- `/home/moshpitcodes/Development/template-claude/.claude/commands/*`
- `/home/moshpitcodes/Development/template-claude/.claude/hooks/scripts/*`
- `/home/moshpitcodes/Development/template-claude/sync-claude-config.sh`
Destination (OpenCode):
- `.opencode/commands/*`
- `.opencode/plugins/*`
- `.opencode/tools/td.ts`
- `.opencode/settings/environment/*`
- `copy-opencode.sh` (plus new multi-repo sync if desired)
- `README.md`, `AGENTS.md`, `.opencode/AGENTS_INDEX.md`, `.opencode/plugins/README.md`
 Commands Parity (Claude → OpenCode)
Add/port these commands into `.opencode/commands/`:
- `build.md` (Claude has it; OpenCode missing)
  - Reads a plan file; ensures TD tasks exist; executes phases; uses `/task-with-td` for delegation
  - Uses the OpenCode custom TD tool (`TD(action: ...)`) with TD CLI under the hood
- `git_status.md` (missing)
  - Standardized git status, branch, diff summary
- `question.md` (missing)
  - Explicit read-only mode: answer-only, no edits
- `plan_w_team.md` (missing)
  - Planning-only orchestration plan (no execution) adapted to OpenCode Task tool realities + TD subagent limitations
Decisions:
- Keep `sentient.md` as a safe demo/regression-test command to verify `rm -rf` is blocked (must not risk deleting real files).
Update existing OpenCode `/plan`:
- Add `## TD Tasks` section (task titles, type/priority, acceptance criteria, mapping to steps)
 Claude Hook Parity Map (Python hooks → OpenCode plugins)
Already covered (confirm behavior/log names align):
- Security check → `.opencode/plugins/security.ts`
- Tool logging (before/after + events) → `.opencode/plugins/logging.ts`
- Markdown validation → `.opencode/plugins/markdown-validator.ts`
- Notifications → `.opencode/plugins/notifications.ts`
- TD enforcement + handoff reminders → `.opencode/plugins/td-enforcer.ts`
- Post-stop monitoring → `.opencode/plugins/post-stop-detector.ts`
To implement for parity (OpenCode-native equivalents):
- Session start context injection (`session_start.py`)
  - On `session.created`: collect git summary + last commit; optionally GH issues (`gh issue list`) when available; emit as a user-visible context message and log it.
- Session end logging (`session_end.py`)
  - On `session.idle`: write a session-end record; include high-level stats (tools used/files edited) if available.
- User prompt auditing (`user_prompt_submit.py --store-last-prompt`)
  - On user message events: append to `.opencode/logs/user_prompts.jsonl` and store last prompt in `.opencode/data/last_prompt.txt`.
- Tool failure context (`post_tool_use_failure.py`)
  - On tool failures: log `.opencode/logs/tool_failures.jsonl` and provide actionable tips (toast and/or injected context if supported).
- Permission request auditing (`permission_request.py`)
  - Ensure permission events are logged in a dedicated parity log (even if general logging already captures them).
- Transcript backups (`pre_compact.py`)
  - On `session.compacted`: back up OpenCode’s own JSONL logs and any session metadata to `.opencode/logs/transcript_backups/` (since OpenCode may not expose Claude-style transcript files).
- Subagent lifecycle tracking (`subagent_start.py` / `subagent_stop.py`)
  - Use Task tool invocations as lifecycle markers; log start/stop to `.opencode/logs/subagents.jsonl`.
- Idle incomplete-work detector (`idle_detector.py`)
  - On `session.idle`: scan recent tool/log entries (and optionally recently edited files) for TODO/FIXME markers; emit warning toast + log `.opencode/logs/idle_detector.jsonl`.
  - Note: no hard “block stop” behavior; warn-only.
 Implementation Phases
Phase 1: Commands + plan format
- Add: build/git_status/question/plan_w_team/sentient
- Update /plan to include TD Tasks
 Phase 2: Plugin parity layer
- Implement the missing parity behaviors as plugins (prefer extending existing ones)
- Standardize log file names/locations to match Claude template intent
 Phase 3: Docs + index + optional sync script
- Update README/AGENTS/AGENTS_INDEX/plugins README
- Optional: add `sync-opencode-config.sh` modeled after `sync-claude-config.sh`
 TD Tasks
Create TD tasks to track and execute this work:
1) Epic: Adopt template-claude full parity (no statusline)
2) TASK: Inventory deltas + define parity targets
3) FEATURE: Port commands (build/git_status/question/plan_w_team)
4) ENHANCEMENT: Update /plan with TD Tasks section
5) FEATURE: Plugin parity layer (session start context, prompt audit, tool failure context, backups, subagent tracking, idle detector, permission auditing)
6) CHORE: Optional sync-opencode-config.sh
7) DOCS: Update docs/indexes
 Acceptance Criteria
- OpenCode template exposes all adopted commands and they work end-to-end
- Plugin layer produces parity JSONL audit trails: session/tool_use/tool_failures/permissions/subagents/user_prompts/transcript_backups/idle_detector
- TD workflow is first-class in both planning and execution commands
- Known limitations are documented (no stop-blocking, transcript-path differences, etc.)
 Validation Commands
- `cd .opencode && bun install`
- `cd .opencode && bun run tsc --noEmit`
- Smoke tests:
  - `/plan "..."` includes TD Tasks section
  - `/git_status` works
  - `/question "..."` stays read-only
  - `/build <plan-path>` follows the plan structure
TD CLI commands to create the planning tasks (run after plan mode)
td create "Adopt template-claude into template-opencode (full parity, no statusline)" --type epic --priority P1 --description "Port Claude-template workflow improvements (commands + hook-equivalent automation + TD-forward planning/build) into OpenCode-native commands/plugins, excluding status line features."
td create "Inventory deltas + define parity targets" --type task --priority P1 --description "Inventory template-claude vs template-opencode deltas; define exact parity targets and OpenCode limitations."
td create "Port Claude commands to OpenCode (build/git_status/question/plan_w_team)" --type feature --priority P1 --description "Add missing slash commands to .opencode/commands and adapt to OpenCode runtime/tooling constraints."
td create "Update /plan template to include TD Tasks section" --type enhancement --priority P1 --description "Modify .opencode/commands/plan.md to include explicit TD Tasks + acceptance criteria mapping."
td create "Implement plugin parity layer for Claude hooks" --type feature --priority P1 --description "Add/extend OpenCode plugins to cover session-start context, user prompt capture, tool failure context, transcript-equivalent backups on compact, subagent tracking, idle detector warnings, permission auditing parity."
td create "Optional: sync-opencode-config.sh" --type chore --priority P3 --description "Add a multi-repo sync script for .opencode mirroring sync-claude-config.sh behavior."
td create "Docs + index updates for new workflows" --type docs --priority P2 --description "Update README.md, AGENTS.md, .opencode/AGENTS_INDEX.md, and .opencode/plugins/README.md."
