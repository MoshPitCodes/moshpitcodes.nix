# Implementation Plans Directory

This directory contains implementation plans created by the product-manager agent and `/plan` command.

## Purpose

Implementation plans are technical blueprints that describe:
- What needs to be built
- Why it's needed
- How to implement it
- What files are involved
- Step-by-step tasks
- TD tasks for tracking

## Usage

**Creating plans:**
```bash
# Via command
/plan "implement OAuth2 authentication"

# Via product-manager agent
@product-manager "create a plan to add OAuth2 authentication"
```

**Implementing plans:**
```bash
# Via build command with TD tracking
/build .claude/plans/oauth2-authentication.md
```

## Plan Format

Plans follow a structured format including:
- Task description and objectives
- Relevant files (existing and new)
- Implementation phases (for complex tasks)
- TD tasks for tracking
- Step-by-step implementation tasks
- Testing strategy
- Success criteria

## Directory Structure

```
.claude/plans/
├── README.md                           # This file
├── <feature-name>-plan.md             # Implementation plans
└── <task-name>-implementation.md       # Technical implementations
```

## Related Directories

- `docs/prd/` - Product Requirements Documents
- `docs/roadmaps/` - Product roadmaps and strategy
- `docs/stories/` - User stories and requirements
- `specs/` - Legacy specs directory (deprecated)
