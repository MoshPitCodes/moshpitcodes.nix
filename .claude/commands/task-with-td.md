---
allowed-tools: Task, mcp__td-sidecar__td_get_status, mcp__td-sidecar__td_create_issue, mcp__td-sidecar__td_start_task, mcp__td-sidecar__td_log_entry, mcp__td-sidecar__td_submit_review
argument-hint: <subagent_type> <task_description>
description: Launch a sub-agent with TD context enforcement
---

# Task with TD Context

This command wraps the built-in Task tool to ensure TD context is properly propagated to sub-agents.

## Workflow

1. **Check TD Status**
   - Verify active task exists
   - Get current task details

2. **Prepare Sub-Agent Context**
   - Include TD requirements in prompt
   - Pass current task information
   - Add enforcement reminders

3. **Launch Sub-Agent**
   - Invoke Task tool with enhanced prompt
   - Monitor sub-agent execution

4. **Post-Execution**
   - Link modified files to TD task
   - Log work completion
   - Update task status

## Instructions for Agent

When this command is invoked:

### Step 1: Check TD Status

Use the MCP tool to get current status:

```json
mcp__td-sidecar__td_get_status({})
```

**If no active task (no focus or in_progress tasks):**
1. STOP and inform user
2. Suggest creating a new task:
   ```json
   mcp__td-sidecar__td_create_issue({
     "title": "<description>",
     "type": "task",
     "priority": "P1"
   })
   ```
   Then start it with:
   ```json
   mcp__td-sidecar__td_start_task({"task": "<task-id>"})
   ```
3. Wait for user to start task
4. DO NOT proceed without active task

**If task exists:**
1. Extract task details (id, key, title) from the status response
2. Save for later linking

### Step 2: Build Enhanced Prompt

Construct the sub-agent prompt with TD enforcement:

```
[Original task description]

---
CRITICAL TD ENFORCEMENT RULES:
---

You are working on TD task: [TASK-KEY] - [TASK-TITLE]

Before modifying ANY files, you MUST:

1. Check TD status using MCP tool:
   ```json
   mcp__td-sidecar__td_get_status({})
   ```

2. Verify the following task is active (check the "focus" field):
   - ID: [TASK-ID]
   - Key: [TASK-KEY]
   - Title: [TASK-TITLE]

3. If status shows NO active task (no "focus" or empty "inProgress"):
   - ❌ STOP immediately
   - ❌ DO NOT write/edit files
   - 🛑 Report error to user

4. Log your progress at key milestones:
   ```json
   mcp__td-sidecar__td_log_entry({
     "message": "Description of what you completed"
   })
   ```

5. After completing work:
   - List all files you modified
   - I will link them to the task

IMPORTANT: Sub-agents do NOT inherit TD plugin enforcement. You must
manually verify TD status before file operations and log your progress.

Current TD Status:
[paste mcp__td-sidecar__td_get_status output here]

---
END TD ENFORCEMENT RULES
---

Now proceed with the task.
```

### Step 3: Invoke Task Tool

Use the Task tool with the enhanced prompt:

```typescript
Task({
  subagent_type: "[specified-agent]",
  prompt: "[enhanced-prompt-from-step-2]"
})
```

### Step 4: Post-Execution Summary

After sub-agent completes:

1. **Review sub-agent's work:**
   - Check if sub-agent logged progress using `mcp__td-sidecar__td_log_entry`
   - Verify task is still in progress or ready for review

2. **Add completion summary:**
   ```json
   mcp__td-sidecar__td_log_entry({
     "message": "Delegated to [agent-type]: [brief-summary]"
   })
   ```

3. **If work is complete, optionally submit for review:**
   ```json
   mcp__td-sidecar__td_submit_review({
     "task": "[TASK-KEY]"
   })
   ```

4. **Confirm to user:**
   "✅ Sub-agent completed work on task [TASK-KEY]. See TD logs for details."

**Note**: TD's file tracking system automatically links modified files when using the TD plugin. The sub-agent should log their own progress using `mcp__td-sidecar__td_log_entry`.

## Example Usage

```
/task-with-td staff-engineer "implement user authentication with JWT"
```

**Agent Actions:**
1. Calls `mcp__td-sidecar__td_get_status({})`
2. Verifies task "AUTH-123" is active (from "focus" field)
3. Builds enhanced prompt with TD rules and MCP tool instructions
4. Calls `Task(subagent_type: "staff-engineer", prompt: "...")`
5. Sub-agent works (with TD reminders in context, uses MCP tools for logging)
6. Sub-agent logs progress: `mcp__td-sidecar__td_log_entry({"message": "Implemented JWT authentication"})`
7. Main agent logs delegation: `mcp__td-sidecar__td_log_entry({"message": "Delegated to staff-engineer: JWT implementation"})`

## Error Handling

### No TD Task Active
```
❌ Error: No TD task active

Before using sub-agents, create and start a task:

1. Create task:
   mcp__td-sidecar__td_create_issue({
     "title": "implement feature X",
     "type": "task"
   })

2. Start task:
   mcp__td-sidecar__td_start_task({
     "task": "<returned-task-id>"
   })
```

### Sub-Agent Didn't Log Progress
```
⚠️  Warning: Sub-agent completed but didn't log progress

Recommendation: Update the sub-agent prompt to emphasize using:
  mcp__td-sidecar__td_log_entry({"message": "..."})

at key milestones during work.
```

## Benefits

1. **MCP-based TD integration** - Uses TD MCP server for reliable task management
2. **Explicit TD checking** - Forces verification before sub-agent launch
3. **Context propagation** - Sub-agent receives TD requirements with MCP tool instructions
4. **Progress logging** - Sub-agents can log their progress using MCP tools
5. **Audit trail** - All sub-agent work tracked in TD logs via MCP

## Limitations

- Sub-agents still don't have plugin-level enforcement
- Relies on LLM following TD instructions in prompt
- User can still use built-in Task tool directly (bypassing this wrapper)
- Sub-agents must have access to TD MCP tools (inherited from parent agent)

## Recommendation

**Use this command instead of direct Task tool when:**
- Working with code files that need TD tracking
- Delegating work from product manager or staff engineer
- Following task-driven development workflow
- Need structured progress logging

**Use built-in Task tool for:**
- Exploratory analysis (no file modifications)
- Read-only operations
- Quick checks that don't need tracking
- Work not associated with TD tasks
