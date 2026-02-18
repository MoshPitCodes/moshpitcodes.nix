---
allowed-tools: Bash, Read, Grep, Glob
argument-hint: [question]
description: Answer questions about the project without making changes
---

# Question

Answer the user's question by analyzing the project structure and documentation.

## Rules

- This is a question-answering task only.
- DO NOT write, edit, or create any files.
- If the question would require code changes, describe the approach conceptually without implementing.

## Execute

- `git ls-files`

## Read

- `README.md`

## Question

$ARGUMENTS
