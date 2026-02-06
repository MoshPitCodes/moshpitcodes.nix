---
allowed-tools: Read, Write, Glob, Grep, Bash, Task
argument-hint: [user prompt] [orchestration prompt]
description: Create an implementation plan with team-based orchestration (builder/validator pattern) and save it to .opencode/plans/
---

# Plan With Team

Create a detailed implementation plan based on the user's requirements. Analyze the request, think through the implementation approach, and save a comprehensive specification document that can be executed by a team lead orchestrating builders and validators.

## Variables

USER_PROMPT: $1
ORCHESTRATION_PROMPT: $2 - (Optional) Guidance for team assembly, task structure, and execution strategy
PLAN_OUTPUT_DIRECTORY: `.opencode/plans/`
TEAM_AGENTS_DIRECTORY: `.opencode/agents/team/`

## Instructions

- **PLANNING ONLY**: Do NOT build, write code, or deploy agents. Your only output is a plan document saved to `PLAN_OUTPUT_DIRECTORY`.
- If no `USER_PROMPT` is provided, stop and ask the user to provide it.
- If `ORCHESTRATION_PROMPT` is provided, use it to guide team composition, task granularity, dependency structure, and parallel/sequential decisions.
- Carefully analyze the user's requirements provided in the USER_PROMPT variable.
- Determine the task type (chore|feature|refactor|fix|enhancement) and complexity (simple|medium|complex).
- Think deeply about the best approach to implement the requested functionality or solve the problem.
- Read the codebase directly to understand existing patterns and architecture. Do NOT use subagents for research.
- Read the team agent definitions in `TEAM_AGENTS_DIRECTORY` to understand available team members and their capabilities.
- Follow the Plan Format below to create a comprehensive implementation plan.
- Include all required sections and conditional sections based on task type and complexity.
- Generate a descriptive, kebab-case filename based on the main topic of the plan.
- Save the complete implementation plan to `PLAN_OUTPUT_DIRECTORY/<descriptive-name>.md`.
- Ensure the plan is detailed enough that the team lead agent could follow it to orchestrate the implementation.
- Include code examples or pseudo-code where appropriate to clarify complex concepts.
- Consider edge cases, error handling, and scalability concerns.

### Team Orchestration Context

The plan you create will be executed by a **team lead** agent that coordinates work using these patterns:

**Available Team Agents:**
- **team-lead** (Opus) — Orchestrator that deploys builders and validators. Never writes code directly. Uses Task tools for coordination.
- **team-builder** (Sonnet) — Focused worker that executes ONE implementation task at a time. Has full write/edit access.
- **team-validator** (Haiku) — Read-only agent that verifies builder work against acceptance criteria. Cannot modify files.

**Execution Model:**
1. Team lead reads the plan and creates tasks using `TaskCreate`
2. Lead sets dependencies between tasks using `TaskUpdate` with `addBlockedBy`
3. Lead deploys builder agents for implementation tasks (parallel when independent)
4. After each builder completes, lead deploys a validator to verify work
5. If validator finds issues, lead resumes/redeploys the builder with feedback
6. Process continues until all tasks are completed and validated

**Task Tools Available to the Lead:**
- `TaskCreate` — Create tasks with subject, description, and activeForm
- `TaskUpdate` — Update status (pending/in_progress/completed), owner, dependencies (addBlockedBy)
- `TaskList` — View all tasks and their current state
- `TaskGet` — Get full details of a specific task
- `Task` — Deploy an agent (builder or validator) to execute work

## Workflow

IMPORTANT: **PLANNING ONLY** — Do not execute, build, or deploy. Output is a plan document.

1. **Analyze Requirements** — Parse the USER_PROMPT to understand the core problem and desired outcome
2. **Understand Codebase** — Directly read existing patterns, architecture, and relevant files (no subagents)
3. **Read Team Agents** — Review `.opencode/agents/team/*.md` to understand team capabilities
4. **Design Solution** — Develop technical approach including architecture decisions and implementation strategy
5. **Define Team Members** — Use `ORCHESTRATION_PROMPT` (if provided) to guide team composition. Identify needed builders and validators. Document in plan.
6. **Define Step-by-Step Tasks** — Write out tasks with IDs, dependencies, assignments. Use `ORCHESTRATION_PROMPT` (if provided) to guide task granularity and parallel/sequential structure.
7. **Generate Filename** — Create a descriptive kebab-case filename based on the plan's main topic
8. **Save Plan** — Write the plan to `PLAN_OUTPUT_DIRECTORY/<filename>.md`
9. **Self-Validate** — Run the file validator to confirm the plan was saved correctly and contains all required sections:
   ```
   uv run .opencode/hooks/validators/file_validator.py --directory .opencode/plans --extension .md --modified-within 300 --contains "## Team Orchestration" --contains "## Step-by-Step Tasks" --contains "## Acceptance Criteria" --contains "## Validation Commands"
   ```
   If validation fails, fix the plan before reporting.
10. **Report** — Provide a summary following the Report section format

## Plan Format

Replace `<content description>` placeholders with actual content. Everything NOT in angle brackets should be written exactly as shown.

```md
# Plan: <task name>

## Task Description
<describe the task in detail based on the prompt>

## Objective
<clearly state what will be accomplished when this plan is complete>

## Problem Statement
<clearly define the specific problem or opportunity this task addresses>

## Solution Approach
<describe the proposed solution approach and how it addresses the objective>

## Relevant Files
Use these files to complete the task:

<list files relevant to the task with bullet points explaining why>

### New Files
<list any new files to be created, if applicable>

## Implementation Phases

### Phase 1: Foundation
<describe any foundational work needed>

### Phase 2: Core Implementation
<describe the main implementation work>

### Phase 3: Integration & Polish
<describe integration, testing, and final touches>

## Team Orchestration

The team lead orchestrates all work. The lead NEVER writes code directly — it uses Task tools to coordinate team members.

### Team Members

<list the team members needed to execute this plan>

- **Builder: <unique-name>**
  - Role: <the specific focus of this builder>
  - Agent Type: team-builder (or a specialized agent from .opencode/agents/ if more appropriate)

- **Validator: <unique-name>**
  - Role: <what this validator checks>
  - Agent Type: team-validator

<continue with additional team members as needed>

## Step-by-Step Tasks

Execute every step in order. Each task maps to a `TaskCreate` call by the team lead.

### 1. <First Task Name>
- **Task ID**: <unique-kebab-case-id>
- **Depends On**: none
- **Assigned To**: <team member name>
- **Agent Type**: <agent type>
- **Parallel**: <true if can run alongside other tasks, false if sequential>
- <specific action to complete>
- <specific action to complete>

### 2. <Second Task Name>
- **Task ID**: <unique-id>
- **Depends On**: <previous Task ID>
- **Assigned To**: <team member name>
- **Agent Type**: <agent type>
- **Parallel**: <true/false>
- <specific action>
- <specific action>

### N. Final Validation
- **Task ID**: validate-all
- **Depends On**: <all previous Task IDs>
- **Assigned To**: <validator team member>
- **Agent Type**: team-validator
- **Parallel**: false
- Run all validation commands
- Verify all acceptance criteria are met

## Acceptance Criteria
<list specific, measurable criteria that must be met for the task to be considered complete>

## Validation Commands
Execute these commands to validate the task is complete:

<list specific commands to validate the work>

## Notes
<optional additional context, considerations, or dependencies>
```

## Report

After creating and saving the implementation plan, provide a concise report:

```
Plan Created

File: .opencode/plans/<filename>.md
Topic: <brief description of what the plan covers>

Key Components:
- <main component 1>
- <main component 2>
- <main component 3>

Team Members:
- <list of team members and their roles>

Task Summary:
- <list of tasks and assigned owner>

To execute this plan, the team lead agent can be invoked to parse and orchestrate the work.
```
