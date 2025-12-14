## Relevant Files and Folders

- `CLAUDE.md` - This file (AI assistant configuration)
- `.claude/agents/` - Specialized AI agents
- `.claude/commands/` - Custom slash commands
- `.claude/skills/` - Claude Code skills
- `docs/` - Project documentation

## General

- Always follow the project's coding standards and style guide
- Always write clear and concise documentation for your code
- Always write unit tests for new features and bug fixes
- Always use meaningful variable and function names
- Always handle errors and exceptions gracefully

## Git Workflow

Git operations (branching, commits, PRs, releases) are managed by the `git-flow-manager` agent.
See `.claude/agents/claude-git-flow-manager.md` for Git Flow conventions and commit message formats.

## Available Slash Commands

| Command | Description |
|---------|-------------|
| /claude-create-architecture-docs | Generate architecture docs with diagrams |
| /claude-refactor-code | Code refactoring guidance |
| /claude-ultrathink | Deep analysis and problem solving |
| /structured-contemplation | Expert guide for contemplation/problem-solving |
| /structured-reflection | Expert guide for reflection techniques |
| /systematic-diagnosis | Issue diagnosis and root cause analysis |
| /systematic-implementation | Validation-driven feature implementation |

## Available Specialized Agents

| Agent | Use Case |
|-------|----------|
| claude-code-architecture-review | Review code for best practices |
| claude-expert-agent-creation | Creating specialized agents |
| claude-expert-code-review | Code review for quality |
| claude-expert-command-creation | Creating slash commands |
| claude-expert-error-detective | Log analysis and debugging |
| claude-expert-mcp-server | MCP server integration |
| claude-expert-prompt-engineering | LLM prompt optimization |
| claude-git-flow-manager | Git Flow workflows |
| claude-markdown-formatter | Markdown formatting |
| claude-mlops-engineer | ML pipelines and MLOps |
| claude-security-engineer | Security/compliance specialist |
| mpc-devops-infrastructure | DevOps, K8s, Terraform, CI/CD |
| mpc-golang-backend-api | Go backend APIs |
| mpc-golang-tui-bubbletea | Go TUI with Bubbletea |
| mpc-java-kotlin-maven-gradle-backend | Java/Kotlin Spring backend |
| mpc-nextjs-fullstack | Next.js 14+ App Router full-stack |
| mpc-nixos | NixOS, Nix Flakes, Home Manager |
| mpc-react-typescript | React + TypeScript frontend |
| mpc-sveltekit-frontend | Svelte 5 + SvelteKit frontend |
| mpc-sveltekit-fullstack | SvelteKit full-stack apps |

## Available Skills

| Skill | Purpose |
|-------|---------|
| artifacts-builder | Build complex React/Tailwind HTML artifacts |
| document-skills | Document manipulation (docx, pdf, pptx, xlsx) |
| mcp-builder | Create MCP servers |
| skill-creator | Create new skills |
| theme-factory | Style artifacts with themes (10 presets) |
