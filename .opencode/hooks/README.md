# Git Hooks for TD Enforcement

This directory contains Git hook templates for enforcing task-driven development workflows with TD.

## Available Hooks

### `pre-commit.template`

Ensures all code changes are linked to a TD task before allowing commit.

**Features:**
- ✅ Checks for active TD task
- ✅ Validates trackable files (code, not build artifacts)
- ✅ Auto-links unlinked files to current task
- ✅ Provides helpful error messages
- ✅ Can be bypassed when necessary

**Installation:**

```bash
# Copy template to git hooks directory
cp .opencode/hooks/pre-commit.template .git/hooks/pre-commit

# Make executable
chmod +x .git/hooks/pre-commit
```

**Usage:**

Normal commits work as usual:
```bash
git add src/file.ts
git commit -m "implement feature"
# → Hook runs automatically
# → Checks TD status
# → Links files if needed
# → Allows commit if task is active
```

**Bypass (when necessary):**
```bash
git commit --no-verify
```

**When to bypass:**
- Emergency hotfixes
- Non-code changes (docs, configs)
- Initial repository setup
- Fixing broken state

**When NOT to bypass:**
- Regular feature development
- Bug fixes
- Refactoring
- Any code changes that should be tracked

---

## How It Works

### 1. Pre-Commit Hook Flow

```
Git Commit Triggered
        ↓
Check if TD installed ──→ NO ──→ Skip validation (warn)
        ↓ YES
Check if TD initialized ──→ NO ──→ Skip validation (warn)
        ↓ YES
Get staged files
        ↓
Filter trackable files (code, not build artifacts)
        ↓
Get TD status (active task?)
        ↓
    NO TASK? ──→ ABORT with error + instructions
        ↓ YES (task active)
Check if files linked to task
        ↓
    UNLINKED? ──→ Auto-link files
        ↓
Allow commit ✅
```

### 2. File Filtering

**Tracked Extensions:**
- Code: `.ts`, `.tsx`, `.js`, `.jsx`, `.go`, `.py`, `.java`, `.kt`, `.rs`, etc.
- Config: `.yaml`, `.yml`, `.toml`, `.json`
- Docs: `.md`
- Scripts: `.sh`

**Excluded Directories:**
- `node_modules/`, `dist/`, `build/`
- `.git/`, `target/`, `vendor/`
- `.opencode/logs/`, `.opencode/data/`
- Framework dirs: `.next/`, `.nuxt/`, `.svelte-kit/`

### 3. Auto-Linking

If files are not linked to the current task, the hook automatically runs:
```bash
td link <current-task> <file1> <file2> ...
```

This ensures all committed code is tracked without manual intervention.

---

## Installation for Team

### Option 1: Manual (Per Developer)

Each developer runs:
```bash
cp .opencode/hooks/pre-commit.template .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

**Pros:** Simple, explicit
**Cons:** Relies on developer memory

### Option 2: Automated (Recommended)

Add to project setup script (e.g., `scripts/setup.sh`):
```bash
#!/bin/bash
# Setup script for new developers

# Install git hooks
if [ ! -f ".git/hooks/pre-commit" ]; then
    echo "Installing TD pre-commit hook..."
    cp .opencode/hooks/pre-commit.template .git/hooks/pre-commit
    chmod +x .git/hooks/pre-commit
    echo "✅ Pre-commit hook installed"
fi
```

Then add to `README.md`:
```markdown
## Setup

Run the setup script to install Git hooks:
```bash
./scripts/setup.sh
```
```

### Option 3: Git Config (Core.hooksPath)

Use custom hooks directory (Git 2.9+):
```bash
# One-time setup
git config core.hooksPath .opencode/hooks

# Copy and make executable
cp .opencode/hooks/pre-commit.template .opencode/hooks/pre-commit
chmod +x .opencode/hooks/pre-commit
```

**Pros:** Automatic for all team members
**Cons:** Requires Git 2.9+, affects all repositories

---

## Troubleshooting

### Hook Not Running

**Check if executable:**
```bash
ls -la .git/hooks/pre-commit
# Should show: -rwxr-xr-x (with x flags)
```

**Fix permissions:**
```bash
chmod +x .git/hooks/pre-commit
```

### Hook Always Skips Validation

**Check TD installation:**
```bash
which td
# Should output: /usr/bin/td or similar
```

**Check TD initialization:**
```bash
ls -la .todos/
# Should show: issues.db
```

### Hook Blocks Valid Commits

**Check TD status:**
```bash
td status --json
```

**Expected output with active task:**
```json
{
  "focus": { "id": "...", "key": "TASK-123", "title": "..." },
  "in_progress": [...],
  ...
}
```

**If no task active:**
```bash
td start <task-id>
# or
td create "description" --start
```

### Emergency Bypass

**When hook is blocking legitimate work:**
```bash
git commit --no-verify -m "emergency fix"
```

**Then fix retroactively:**
```bash
# Create/start task
td create "Retroactive tracking for commit abc123" --start

# Link modified files
td link TASK-XXX <files...>
```

---

## Customization

### Adjust Trackable Extensions

Edit `pre-commit.template` line:
```bash
TRACKABLE_EXTENSIONS="\.(ts|tsx|js|jsx|...)$"
```

Add or remove extensions as needed for your project.

### Adjust Excluded Directories

Edit `pre-commit.template` line:
```bash
EXCLUDED_PATTERNS="node_modules/|dist/|..."
```

Add project-specific build/generated directories.

### Change Behavior

**Make hook stricter (no auto-linking):**
```bash
# Replace auto-link section with:
echo "❌ Files not linked. Please link manually:"
echo "  td link $TASK_KEY $UNLINKED_FILES"
exit 1
```

**Make hook more lenient (warnings only):**
```bash
# Replace exit 1 with:
echo "⚠️  Warning: No task active, but allowing commit"
exit 0
```

---

## Best Practices

### 1. Install Immediately
Install hooks as part of repository onboarding, not as afterthought.

### 2. Document Bypass Scenarios
Make clear when `--no-verify` is acceptable.

### 3. Keep Templates Updated
When TD workflow changes, update templates and notify team.

### 4. Test Before Rolling Out
Test hook in development branch before enabling for whole team.

### 5. Provide Escape Hatches
Always document bypass mechanism for edge cases.

---

## Integration with CI/CD

The pre-commit hook is a **client-side** check. For server-side enforcement:

### GitHub Actions Example

```yaml
name: TD Validation

on: [pull_request]

jobs:
  validate-td:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Install TD
        run: |
          curl -L https://github.com/marcus/td/releases/download/v1.0.0/td-linux -o td
          chmod +x td
          sudo mv td /usr/bin/
      
      - name: Check TD Links
        run: |
          # Get files in PR
          FILES=$(git diff --name-only origin/main...HEAD)
          
          # Check each file is linked
          for file in $FILES; do
            if ! td status --file "$file" | grep -q "linked"; then
              echo "❌ $file is not linked to any TD task"
              exit 1
            fi
          done
          
          echo "✅ All files linked to TD tasks"
```

---

## FAQ

**Q: What if I forgot to start a task?**  
A: The hook will block the commit and show instructions to start/create a task.

**Q: Can I commit without a task?**  
A: Use `git commit --no-verify`, but only for non-code changes or emergencies.

**Q: Does this work with GUI clients?**  
A: Yes, Git hooks work with all clients (command line, VS Code, GitKraken, etc.)

**Q: What about rebasing/cherry-picking?**  
A: Hooks run during these operations too. Use `--no-verify` if needed.

**Q: Can I customize the hook per repository?**  
A: Yes, edit `.git/hooks/pre-commit` directly (won't affect template).

---

## Support

For issues with hooks:
1. Check troubleshooting section above
2. Verify TD installation: `td version`
3. Check hook permissions: `ls -la .git/hooks/`
4. Test hook manually: `.git/hooks/pre-commit`

For TD issues:
- [TD Documentation](https://github.com/marcus/td)
- [TD Integration Guide](.opencode/docs/td-integration.md)

---

**Last Updated:** 2026-02-10  
**Maintained By:** Development Team
