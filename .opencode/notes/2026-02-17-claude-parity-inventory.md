# 2026-02-17 - Template-Claude -> OpenCode Parity Inventory

Context:
- Source repo: `/home/moshpitcodes/Development/template-claude`
- Target repo: `/home/moshpitcodes/Development/template-opencode`
- Goal: adopt template-claude workflow + automation improvements into OpenCode using OpenCode-native mechanisms (commands + TS plugins + tools), excluding status line support.

## Top-Level Deltas

### Commands

Present in Claude template (`.claude/commands/*.md`) but missing in OpenCode template (`.opencode/commands/*.md`):
- `build.md`
- `git_status.md`
- `question.md`
- `plan_w_team.md`
- `sentient.md` (keep, but rework into a safe security regression-test)
- `update_status_line.md` (DROP - status line out of scope)

Already present in both (largely identical intent):
- `plan.md`
- `task-with-td.md` (Claude version uses a dedicated TD integration; OpenCode version uses the custom TD tool and TD CLI)
- `prime.md`
- `structured-thinking.md`
- `ultrathink.md`
- `create-architecture.md`
- `refactor-code.md`
- `all_tools.md`

### Automation / Hooks

Claude template implements automation as Python hooks configured in `.claude/settings.json`.
OpenCode template implements automation as TS plugins in `.opencode/plugins/`.

OpenCode already covers most high-value behaviors:
- security blocking (rm -rf, secrets)
- JSONL logging
- markdown validation (warn-only)
- TD enforcement
- post-stop/orphaned file detector
- notifications + session stats
- context management

Missing parity behaviors that exist in Claude hooks:
- session-start context injection (git status + recent GH issues)
- post-tool-failure contextual guidance log
- user prompt submission audit log (+ optional last prompt store)
- transcript (or equivalent) backup on compaction
- subagent start/stop audit log with duration
- idle detector that warns on TODO/FIXME left behind

### Config & Environment Presets

Claude: `.claude/settings.json` configures Claude Code hooks and statusLine.
OpenCode: `opencode.json` covers permissions + npm plugins; `.opencode/settings/environment/*.json` are env presets.

Notes:
- Permissions: both repos block `rm -rf*` and allow common dev commands. OpenCode uses the newer permission model where `edit` covers all file modifications.
- Status line: Claude has `statusLine` configured; OpenCode parity for status line is explicitly out of scope.
- Preset naming bug: `.opencode/settings/environment/bash-timeouts.json` contents appear to duplicate performance-related settings (likely a copy/paste issue). Not required for parity but worth cleaning up in a later chore.

## Claude Hooks -> OpenCode Plugin Map

OpenCode plugin events reference: https://opencode.ai/docs/plugins (notably `session.created`, `session.idle`, `session.compacted`, `tool.execute.before`, `tool.execute.after`, `permission.asked`, `permission.replied`, `message.updated`).

| Claude Hook Event | Claude Script | Behavior | OpenCode Hook/Event(s) | OpenCode Implementation Plan |
|---|---|---|---|---|
| Setup | `setup.py` | Ensure `.claude/logs`, backups dirs exist; log setup | plugin init | Ensure `.opencode/logs`, `.opencode/data`, backups dirs exist (most plugins already `mkdir`). Optionally consolidate into a small “bootstrap” plugin or keep per-plugin. |
| SessionStart | `session_start.py --load-context` | Log session_start; optionally inject dev context message (git + recent GH issues); load docs snippets | `event: session.created` | Add a plugin that (1) logs `session_start.jsonl` (2) computes git summary and optionally `gh issue list` (best-effort) (3) presents a toast + writes a structured context file under `.opencode/data/session_context/<sessionID>.md` for humans. (True “inject into model context” is not a documented hook; treat parity as: visible toast + persisted context file + logs.) |
| SessionEnd | `session_end.py` | Log session_end; optional cleanup | `event: session.idle` (and possibly `session.deleted`) | Extend logging/notifications to write `session_end.jsonl` record (reason + timestamps). |
| UserPromptSubmit | `user_prompt_submit.py --store-last-prompt` | Log prompt submission (length); optionally store last prompt text | `event: message.updated` (or message events) | Feasibility check: confirm event payload includes message content. If yes: log length + (optional) content to `.opencode/logs/user_prompts.jsonl` + store `.opencode/data/last_prompt.txt`. If not: log only metadata available (role, message id) and rely on existing `messages.jsonl` logging. |
| PreToolUse | `security_check.py` | Block dangerous ops and secret files | `tool.execute.before` | Already implemented via `.opencode/plugins/security.ts`. Confirm parity vs Claude patterns (system path writes are currently blocked more broadly in OpenCode implementation). |
| PreToolUse (Edit/Write) | `td_enforcer.py` | Gate writes without TD focus; auto-link file | `tool.execute.before` + file edit events | Already implemented via `.opencode/plugins/td-enforcer.ts`. Verify OpenCode uses correct permission events (`permission.asked` vs `permission.updated` in current logging plugin). |
| PostToolUse | `tool_logger.py` | Log tool_use JSONL | `tool.execute.before/after` | Already implemented via `.opencode/plugins/logging.ts` (writes `tool_use.jsonl`). |
| PostToolUse (Edit/Write) | `markdown_validator.py` | Validate markdown; inject warnings | `event: file.edited` | Already implemented warn-only via `.opencode/plugins/markdown-validator.ts`. |
| PostToolUseFailure | `post_tool_use_failure.py` | Log tool failure + inject debugging tips | `tool.execute.after` and/or `session.error` | Add a plugin (or extend logging plugin) to detect tool failures (needs payload details). Write `.opencode/logs/tool_failures.jsonl` and send a toast with tool-specific tips. |
| PreCompact | `pre_compact.py` | Back up transcript file before compaction | `event: session.compacted` and/or `experimental.session.compacting` | Implement “transcript-equivalent” backups: snapshot `.opencode/logs/*.jsonl` and key `.opencode/data/*` into `.opencode/logs/transcript_backups/<sessionID>/<timestamp>/`. |
| SubagentStart | `subagent_start.py` | Log subagent start event | `tool.execute.before` when `tool==task` | Add plugin to log `subagents.jsonl` on Task tool calls. Capture subagent type + description; store returned task_id if available in tool output. |
| SubagentStop | `subagent_stop.py` | Log completion + duration by reading prior start time | `tool.execute.after` when `tool==task` | Same plugin: log stop event and compute duration from stored start time in memory (and/or by reading `subagents.jsonl` like Claude does). |
| Notification | `notification.py` | Log notifications JSONL | `tui.toast.show` (and/or existing notifications plugin) | Likely unnecessary; OpenCode already logs session + tool events. If we want parity log file: add a lightweight plugin that logs `tui.toast.show` events to `notifications.jsonl`. |
| Stop | `idle_detector.py` | On stop, scan recent tool inputs for TODO/FIXME in code changes | `event: session.idle` | Implement warn-only: scan recent entries in `.opencode/logs/tool_use.jsonl` and/or recently edited files for TODO/FIXME. Toast + log `idle_detector.jsonl`. |
| PermissionRequest | `permission_request.py --log-only` | Log permission requests | `permission.asked` + `permission.replied` | Logging plugin already writes `.opencode/logs/permissions.jsonl`, but current implementation references `permission.updated` which may be a stale event name. Update to match docs (`permission.asked`). |

## Concrete Parity Targets (Definition of Done for “Inventory”)

Commands parity targets:
- Add `.opencode/commands/build.md`, `.opencode/commands/git_status.md`, `.opencode/commands/question.md`, `.opencode/commands/plan_w_team.md`, `.opencode/commands/sentient.md`.
- Do not add status line artifacts or `update_status_line`.

Plugins parity targets:
- Add: session-start context logger + persisted context file (best-effort toast)
- Add: tool failure logger + toast tips
- Add: prompt audit logger (metadata at minimum)
- Add: compaction backup snapshotter
- Add: subagent lifecycle logger (Task tool)
- Add: idle detector (warn-only)

Known OpenCode limitations vs Claude:
- No documented “Stop hook that blocks stopping”; implement warn-only at `session.idle`.
- No documented “inject arbitrary extra context into model at session start”; parity achieved via toast + persisted human-readable context file + logs.

## Immediate Follow-Ups

1) During plugin parity task, add a temporary debug plugin (or temporary logging mode) to capture real event payload shapes for:
- `permission.asked` / `permission.replied`
- `message.updated`
- `tool.execute.after` error shapes
This de-risks assumptions about what data we can log.

2) Update `.opencode/plans/adopt-template-claude-full-parity-no-statusline.md` if any parity assumptions change after payload inspection.
