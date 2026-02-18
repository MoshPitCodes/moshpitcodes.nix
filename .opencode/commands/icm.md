---
allowed-tools: Read, Write, Edit, Bash
argument-hint: [context|stats|sweep|manual|prune|distill|compress] [args]
description: Intelligent Context Manager command entrypoint and fallback help
---

ICM (Intelligent Context Manager) command.

Primary behavior is implemented by the context-manager plugin's
`command.execute.before` hook for command `icm`.

Subcommands:
- `context`
- `stats`
- `sweep [N]`
- `manual [on|off]`
- `prune [focus]`
- `distill [focus]`
- `compress [focus]`

If plugin hooks are unavailable, provide concise help and suggest restarting
OpenCode so plugins and commands reload.
