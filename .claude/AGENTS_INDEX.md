# Claude Code Components Index

Complete catalog of all agents, commands, and status lines in the `.claude` directory.

**Last Updated:** 2026-02-11
**Total Components:** 34 agents, 16 commands, 10 status lines

---

## Table of Contents

- [Agents by Category](#agents-by-category)
  - [Frontend Stack](#frontend-stack-4-agents)
  - [Backend Stack](#backend-stack-5-agents)
  - [DevOps & Infrastructure](#devops--infrastructure-3-agents)
  - [Code Quality & Review](#code-quality--review-5-agents)
  - [Meta & System](#meta--system-4-agents)
  - [Integration Specialists](#integration-specialists-2-agents)
  - [Domain Specialists](#domain-specialists-2-agents)
  - [Product & Leadership](#product--leadership-2-agents)
  - [Workflow Automation](#workflow-automation-2-agents)
- [Skills](#skills-8-total)
- [Commands](#commands-6-total)
- [Model Distribution](#model-distribution)

---

## Agents by Category

### Frontend Stack (4 agents)

| Agent | Model | Use Case |
|-------|-------|----------|
| **nextjs-fullstack** | Opus 4.6 | Next.js 16+ App Router full-stack applications |
| **react-typescript** | Opus 4.6 | React + TypeScript frontend development |
| **sveltekit-frontend** | Opus 4.6 | Svelte 5 + SvelteKit frontend-only |
| **sveltekit-fullstack** | Opus 4.6 | Svelte 5 full-stack with PostgreSQL + Tailwind |

### Backend Stack (5 agents)

| Agent | Model | Use Case |
|-------|-------|----------|
| **golang-backend-api** | Opus 4.6 | Go 1.25+ backend APIs and services |
| **golang-tui-bubbletea** | Opus 4.6 | Go terminal UIs with Bubbletea v2 |
| **java-kotlin-backend** | Opus 4.6 | Java 25+ / Kotlin Spring Boot applications |
| **typescript-backend** | Sonnet 4.5 | TypeScript backend APIs (Express, Fastify, NestJS) |
| **discord-golang** | Haiku 4.5 | Discord bots with Go + discordgo |

### DevOps & Infrastructure (3 agents)

| Agent | Model | Use Case |
|-------|-------|----------|
| **devops-infrastructure** | Opus 4.6 | Kubernetes, Docker, Terraform, ArgoCD, CI/CD |
| **nixos** | Opus 4.6 | NixOS, Nix Flakes, Home Manager |
| **git-flow-manager** | Haiku 4.5 | Git Flow branching workflows |

### Code Quality & Review (5 agents)

| Agent | Model | Use Case |
|-------|-------|----------|
| **architecture-review** | Sonnet 4.5 | Code architecture and best practices review |
| **code-review** | Sonnet 4.5 | Code quality, security, maintainability review |
| **database-specialist** | Opus 4.6 | Database design, schema modeling, query optimization |
| **security-engineer** | Sonnet 4.5 | Security infrastructure and compliance |
| **testing-engineer** | Sonnet 4.5 | Test strategy, automation, coverage improvement |

### Meta & System (4 agents)

| Agent | Model | Use Case |
|-------|-------|----------|
| **agent-creation** | Sonnet 4.5 | Creating new Claude Code agents |
| **command-creation** | Sonnet 4.5 | Creating slash commands |
| **mcp-server** | Opus 4.6 | MCP server integration |
| **prompt-engineering** | Sonnet 4.5 | LLM prompt optimization |

### Integration Specialists (2 agents)

| Agent | Model | Use Case |
|-------|-------|----------|
| **linearapp** | Haiku 4.5 | Linear.app issue tracking integration |
| **markdown-formatter** | Haiku 4.5 | Markdown formatting specialist |

### Domain Specialists (2 agents)

| Agent | Model | Use Case |
|-------|-------|----------|
| **hytale-modding** | Sonnet 4.5 | Hytale server mods with Java 25+ / Kotlin |
| **rpg-mmo-systems-designer** | Opus 4.6 | RPG/MMO game systems design |

### Product & Leadership (2 agents)

| Agent | Model | Use Case |
|-------|-------|----------|
| **product-manager** | Sonnet 4.5 | Product strategy, roadmapping, feature prioritization, PRDs |
| **staff-engineer** | Sonnet 4.5 | System architecture, technical strategy, ADRs, RFCs, cross-team leadership |

### Workflow Automation (2 agents)

| Agent | Model | Use Case |
|-------|-------|----------|
| **error-detective** | Sonnet 4.5 | Log analysis and error pattern detection |
| **mlops-engineer** | Opus 4.6 | ML infrastructure and operations |

---

## Skills (8 total)

| Skill | Purpose | Key Features |
|-------|---------|--------------|
| **artifacts-builder** | Create complex HTML artifacts | React 18, Vite, Tailwind, shadcn/ui |
| **mcp-builder** | Build MCP servers | Python FastMCP & Node/TypeScript SDK |
| **skill-creator** | Create new skills | Meta-skill for extending Claude Code |
| **theme-factory** | Style artifacts | 10 pre-set themes + custom generation |
| **docx** | Word document manipulation | Tracked changes, redlining, OOXML |
| **pdf** | PDF manipulation | Extract, create, merge, forms |
| **pptx** | PowerPoint creation | Templates, design palettes, html2pptx |
| **xlsx** | Excel spreadsheets | Formulas, financial modeling, recalc |

---

## Commands (6 total)

| Command | Purpose | Argument Hint |
|---------|---------|---------------|
| **/ultrathink** | Deep analysis and problem solving | `[problem or question]` |
| **/diagnosis** | Systematic issue diagnosis | `[framework]` or flags |
| **/reflection** | Expert guide for reflection | Various |
| **/contemplation** | Contemplation/problem-solving | Various |
| **/refactor-code** | Code refactoring assistance | `[code location]` |
| **/create-architecture** | Generate architecture docs | `[framework]` or flags |

---

## Model Distribution

### By Model Tier

| Model | Count | Usage Pattern |
|-------|-------|---------------|
| **Opus 4.6** | 13 agents | Complex reasoning, architecture, full-stack, orchestration |
| **Sonnet 4.5** | 12 agents | Balanced tasks, code review, meta-agents, implementation |
| **Haiku 4.5** | 4 agents | Fast, deterministic workflows, validation, exploration |

**Total Agents: 29**

### Haiku Agents (Fast & Efficient)
- discord-golang
- git-flow-manager
- linearapp
- markdown-formatter

### Sonnet Agents (Balanced)
- agent-creation
- architecture-review
- code-review
- command-creation
- error-detective
- hytale-modding
- product-manager
- prompt-engineering
- security-engineer
- staff-engineer
- testing-engineer
- typescript-backend

### Opus Agents (Complex & Deep)
- database-specialist
- devops-infrastructure
- golang-backend-api
- golang-tui-bubbletea
- java-kotlin-backend
- mcp-server
- mlops-engineer
- nextjs-fullstack
- nixos
- react-typescript
- rpg-mmo-systems-designer
- sveltekit-frontend
- sveltekit-fullstack

---

## Quick Reference

### Frontend Development
- **React**: `react-typescript`
- **Next.js**: `nextjs-fullstack`
- **Svelte**: `sveltekit-frontend` or `sveltekit-fullstack`

### Backend Development
- **Go**: `golang-backend-api`
- **Java/Kotlin**: `java-kotlin-backend`
- **TypeScript**: `typescript-backend`

### Infrastructure & DevOps
- **Kubernetes/Docker**: `devops-infrastructure`
- **NixOS**: `nixos`
- **Git Workflows**: `git-flow-manager`

### Code Quality
- **Architecture Review**: `architecture-review`
- **Code Review**: `code-review`
- **Security**: `security-engineer`

### Specialized Domains
- **Discord Bots**: `discord-golang`
- **Game Development**: `hytale-modding`, `rpg-mmo-systems-designer`
- **ML Operations**: `mlops-engineer`

---

## Usage Tips

1. **Model Selection**: Higher-tier models (Opus) for complex tasks, lower-tier (Haiku) for simple/fast operations
2. **Fallbacks**: `java-kotlin-backend` includes fallback models for flexibility
3. **Specialization**: Use the most specific agent for your task (e.g., `nextjs-fullstack` instead of generic `react-typescript` for Next.js)
4. **Skills**: Load skills for bundled resources and scripts (e.g., `mcp-builder` for MCP server creation)
5. **Commands**: Use slash commands for systematic workflows (e.g., `/ultrathink` for deep analysis)

---

## Maintenance

To regenerate this index:
```bash
# Coming soon: Auto-generation script
.claude/scripts/generate-index.sh
```

**Contributing**: When adding new agents/skills/commands, update this index or run the generation script.
