---
description: Create a detailed plan with a multi-agent execution strategy and TD task breakdown
argument-hint: [user prompt] [orchestration prompt]
allowed-tools: Read, Grep, Glob, Task
---

# Plan With Team

Create a detailed implementation plan for the user's request, including a team execution strategy and a TD task breakdown.

## Variables

- USER_PROMPT: $1
- ORCHESTRATION_PROMPT: $2 (optional)
- PLAN_OUTPUT_DIRECTORY: `.opencode/plans/`

## Instructions

- PLANNING ONLY: do not build/implement the plan.
- If no USER_PROMPT is provided, STOP and ask for it.
- Use ORCHESTRATION_PROMPT (if provided) to guide task granularity, dependencies, and parallelization.
- Understand the codebase directly (Read/Grep/Glob) to ground the plan in reality.

## Output Requirements

Write a plan document to `PLAN_OUTPUT_DIRECTORY/<descriptive-kebab-case>.md` with:

- Task Description
- Objective
- Problem Statement (for medium/complex work)
- Solution Approach
- Relevant Files
- Implementation Phases
- TD Tasks (createable via `td create ...` with acceptance criteria)
- Step by Step Tasks (each step maps to a TD task)
- Testing Strategy
- Acceptance Criteria
- Validation Commands

## Team Execution Strategy

Include a short section describing how to execute the plan using sub-agents:

- Use `/task-with-td <subagent_type> "..."` for delegated work.
- Sub-agents do NOT inherit TD plugin enforcement; the delegation prompt must explicitly require checking TD status before file writes.
- Avoid collisions: do not assign parallel tasks that edit the same files.

## Report

- Save the plan file and print its path
- List the proposed TD tasks (titles + type/priority)
