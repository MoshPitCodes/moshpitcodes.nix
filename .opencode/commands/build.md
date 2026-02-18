---
description: Implement a plan file with TD task tracking
argument-hint: [path-to-plan]
allowed-tools: Read, Bash, Task
---

# Build

Implement the plan at `$ARGUMENTS` with TD task tracking.

## Workflow

1. Validate input
   - If no path is provided, STOP and ask for the plan path.
   - Read the plan file and identify the major work items.

2. Ensure TD tasks exist
   - Check TD status (`td status --json`).
   - If the plan includes a `## TD Tasks` section, ensure each task exists in TD.
   - If tasks do not exist yet, create them using `td create` (include acceptance criteria in the description).

3. Start the first task
   - `td start <task-id>`
   - Work step-by-step in the order defined by the plan.

4. Track progress
   - Log milestones with `td log "..."`.
   - Link any created/modified files to the active task (`td link <task> <files...>`).

5. Complete tasks sequentially
   - When a plan task is complete: `td review <task-id>`.
   - Start the next task and continue.

6. Delegation (if needed)
   - If you delegate work to a sub-agent, use `/task-with-td <agent> "..."` and include the TD task key in the prompt.

## Report

- List TD tasks created/used and their current statuses
- Summarize what was implemented and where (files/areas)
- Provide validation commands executed (or to run next)
