---
allowed-tools: Bash, Task
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

```bash
td status --json
```

**If no active task:**
1. STOP and inform user
2. Suggest: `td create "<description>" --start`
3. Wait for user to start task
4. DO NOT proceed without active task

**If task exists:**
1. Extract task details (id, key, title)
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

1. Check TD status:
   ```bash
   td status --json
   ```

2. Verify the following task is active:
   - ID: [TASK-ID]
   - Key: [TASK-KEY]
   - Title: [TASK-TITLE]

3. If status shows NO active task:
   - ❌ STOP immediately
   - ❌ DO NOT write/edit files
   - 🛑 Report error to user

4. After completing work:
   - List all files you modified
   - I will link them to the task

IMPORTANT: Sub-agents do NOT inherit TD plugin enforcement. You must
manually verify TD status before every file operation.

Current TD Status:
[paste td status --json output here]

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

### Step 4: Post-Execution Linking

After sub-agent completes:

1. **Ask sub-agent for modified files:**
   "List all files you created or modified during this task."

2. **Link files to TD task:**
   ```bash
   td link [TASK-KEY] [file1] [file2] [file3] ...
   ```

3. **Add completion log:**
   ```bash
   td log "Completed via [agent-type]: [brief-summary]"
   ```

4. **Confirm to user:**
   "✅ Linked [N] files to task [TASK-KEY]"

## Example Usage

```
/task-with-td staff-engineer "implement user authentication with JWT"
```

**Agent Actions:**
1. Runs `td status --json`
2. Verifies task "AUTH-123" is active
3. Builds enhanced prompt with TD rules
4. Calls `Task(subagent_type: "staff-engineer", prompt: "...")`
5. Sub-agent works (with TD reminders in context)
6. Links modified files: `td link AUTH-123 src/auth/*.ts`
7. Logs completion: `td log "Completed via staff-engineer: JWT implementation"`

## Error Handling

### No TD Task Active
```
❌ Error: No TD task active

Before using sub-agents, start a task:
  td create "implement feature X" --start
  
Or focus existing task:
  td start TASK-123
```

### Sub-Agent Violated TD Rules
```
⚠️  Warning: Sub-agent modified files without TD task

Files modified:
  - src/file1.ts
  - src/file2.ts
  
Linking files to task retroactively:
  td link TASK-123 src/file1.ts src/file2.ts
  
Please review these changes.
```

## Benefits

1. **Explicit TD checking** - Forces verification before sub-agent launch
2. **Context propagation** - Sub-agent receives TD requirements in prompt
3. **Post-hoc linking** - Files linked even if sub-agent bypasses enforcement
4. **Audit trail** - All sub-agent work tracked in TD logs

## Limitations

- Sub-agents still don't have plugin-level enforcement
- Relies on LLM following TD instructions in prompt
- User can still use built-in Task tool directly (bypassing this wrapper)

## Recommendation

**Use this command instead of direct Task tool when:**
- Working with code files
- Need TD tracking
- Want automatic file linking
- Following task-driven development workflow

**Use built-in Task tool for:**
- Exploratory analysis (no file modifications)
- Read-only operations
- Quick checks that don't need tracking
