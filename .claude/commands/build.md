---
description: Implement the plan
argument-hint: [path-to-plan]
allowed-tools: mcp__td-sidecar__td_get_status, mcp__td-sidecar__td_create_issue, mcp__td-sidecar__td_start_task, mcp__td-sidecar__td_log_entry, mcp__td-sidecar__td_submit_review
---

# Build

Follow the `Workflow` to implement the `PATH_TO_PLAN` with TD task tracking, then `Report` the completed work.

## Variables

PATH_TO_PLAN: $ARGUMENTS

## Workflow

### Step 1: Validate Input
- If no `PATH_TO_PLAN` is provided, STOP immediately and ask the user to provide it (AskUserQuestion).
- Read the plan at `PATH_TO_PLAN` to understand the work required.

### Step 2: TD Task Creation
**CRITICAL**: Before implementing, ensure TD tasks exist for the work:

1. **Check TD Status:**
   ```json
   mcp__td-sidecar__td_get_status({})
   ```

2. **Create TD Tasks from Plan:**
   - Parse the plan to identify distinct implementation tasks
   - For each major task/milestone in the plan, create a TD issue:
   ```json
   mcp__td-sidecar__td_create_issue({
     "title": "Brief task title from plan",
     "type": "task",
     "priority": "P1",
     "description": "Detailed description including acceptance criteria from plan"
   })
   ```

3. **Start the First Task:**
   ```json
   mcp__td-sidecar__td_start_task({
     "task": "<task-id>"
   })
   ```

### Step 3: Implementation
- Implement the plan step-by-step
- **Log progress at key milestones:**
  ```json
  mcp__td-sidecar__td_log_entry({
    "message": "Completed: <specific achievement>"
  })
  ```
- As you complete tasks, submit them for review and start the next:
  ```json
  mcp__td-sidecar__td_submit_review({"task": "<current-task-id>"})
  mcp__td-sidecar__td_start_task({"task": "<next-task-id>"})
  ```

### Step 4: Delegation (if needed)
If you need to delegate work to specialized agents, use:
```
/task-with-td <agent-type> "Task description with reference to TASK-ID"
```

This ensures sub-agents work within TD context and log their progress.

## Report

- Present the `## Report` section of the plan
- List all TD tasks created with their IDs and status
- Summary of what was implemented and logged to TD