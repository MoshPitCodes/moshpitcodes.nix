# Plan: Migrate Local Project to GitHub Remote Repository

## Task Description
Migrate the local `shifttab.nix` project (new NixOS configurations) to the existing GitHub remote repository `MoshPitCodes/moshpitcodes.nix`, replacing the old configurations while preserving specific files and documentation from the old repository. Git history does not need to be preserved.

## Objective
Push the new NixOS configurations to `github.com/MoshPitCodes/moshpitcodes.nix` with a clean git history, while retaining documentation, CI/CD workflows, and project infrastructure files from the old repository.

## Problem Statement
The local project at `~/Development/shifttab.nix` contains a complete rewrite of NixOS configurations but is not a git repository. The remote repository at `github.com/MoshPitCodes/moshpitcodes.nix` contains the old configurations (~336 commits) along with valuable project infrastructure (CI/CD, docs, wallpapers, GitHub config). We need to merge the new code with the old infrastructure files and push to the remote with a clean history.

## Solution Approach
1. Clone the old remote repository to a temporary location
2. Copy the "keeper" files from the old repo into the local project
3. Initialize git in the local project, add the remote origin
4. Create an initial commit with all files
5. Force push to `main`, replacing the old history entirely

This is the cleanest approach since:
- No history preservation needed
- Avoids complex merge conflicts between old and new Nix configs
- Results in a clean, single-commit starting point

## Relevant Files

### Files to KEEP from Old Remote Repository
These must be copied from the cloned old repo into the local project:

- `.github/` - Full directory including:
  - `.github/workflows/test-configurations.yml` - CI: builds all host configurations
  - `.github/workflows/test-flake.yml` - CI: flake checks
  - `.github/rulesets/` - 5 branch protection rulesets (force-push block, linear history, PR requirement, resolved comments, signed commits)
  - `.github/assets/` - GitHub assets (screenshots, images)
  - `.github/CODEOWNERS` - Code ownership definitions
  - `.github/dependabot.yml` - Dependabot configuration
  - `.github/pull_request_template.md` - PR template
- `docs/` (old repo docs) - Proper user documentation:
  - `docs/README.md` - Docs index
  - `docs/installation.md` - Installation guide
  - `docs/configuration.md` - Configuration reference
  - `docs/development-shells.md` - Dev shell documentation
  - `docs/scripts.md` - Scripts documentation
  - `docs/wsl.md` - WSL2 setup guide
  - `docs/mcp-td-sidecar-integration.md` - MCP/TD integration
  - `docs/templates/` - Document templates
- `wallpapers/mix/` - Actual wallpaper image files (local only has `.gitkeep`)
- `renovate.json` - Renovate dependency update configuration
- `.rsyncignore` - Rsync exclusion patterns
- `SECRETS.md` - Secrets management documentation (old repo version references env vars approach)
- `README.md` - Project README with screenshots and overview
- `LICENSE` - MIT license file
- `.editorconfig` - Editor configuration
- `.gitattributes` - Git attributes

### Files to KEEP from Local Project (New Code)
These are the primary deliverables - the rewritten NixOS configs:

- `flake.nix` - New Nix Flake entry point
- `flake.lock` - Pinned input versions
- `hosts/` - All host configurations (desktop, laptop, vm, vmware-guest, wsl)
- `modules/` - All NixOS + Home Manager modules (core/, home/)
- `overlays/` - Nix package overlays
- `CLAUDE.md` - Updated Claude Code configuration (local version supersedes old)
- `.gitignore` - Will be MERGED (old repo version is more comprehensive)
- `treefmt.toml` - Code formatting config
- `secrets.nix.example` - Secrets template
- `.claude/` - Claude Code agents, commands, hooks, settings (need to update .gitignore to allow this)
- `assets/` - Local assets

### Files to DISCARD
These exist in one or both repos but should NOT be in the final result:

- Old repo's Nix configs (hosts/, modules/, overlays/, flake.nix, etc.) - Replaced by new code
- Old repo's `pkgs/` - Custom packages (monolisa, reposync) - Will be re-added if needed later
- Old repo's `scripts/` - System management scripts - Will be re-added if needed later
- Old repo's `shells/` - Development shells - Will be re-added if needed later
- Old repo's `.sidecar/` - Old sidecar config
- Local `.secrets.nix.swp` - Editor swap file
- Local `secrets.nix` - Contains actual secrets (git-ignored)
- Local `secrets.nix.bak` - Backup file
- Local `.opencode/` - OpenCode config (not needed in repo)
- Local `.todos/` - Local todo state

### New Files to Create
- `.gitignore` (merged) - Combine old repo's comprehensive .gitignore with local entries

## Implementation Phases

### Phase 1: Foundation
- Clone old remote repository to temporary location
- Audit and identify all keeper files from old repo
- Prepare the merged `.gitignore`

### Phase 2: Core Implementation
- Copy keeper files from old repo clone into local project
- Merge documentation directories (old repo docs + local implementation docs)
- Initialize git repository in local project
- Configure git remote pointing to `github.com/MoshPitCodes/moshpitcodes.nix`

### Phase 3: Integration & Polish
- Create comprehensive initial commit
- Verify all expected files are present
- Force push to remote `main` branch
- Validate CI/CD workflows can find expected files
- Clean up temporary clone

## Team Orchestration

- You operate as the team lead and orchestrate the team to execute the plan.
- You're responsible for deploying the right team members with the right context to execute the plan.
- IMPORTANT: You NEVER operate directly on the codebase. You use `Task` and `Task*` tools to deploy team members to do the building, validating, testing, deploying, and other tasks.

### Team Members

- Builder
  - Name: repo-migrator
  - Role: Execute the repository migration - clone old repo, copy files, initialize git, merge configs, commit, and push
  - Agent Type: general-purpose
  - Resume: true

- Builder
  - Name: gitignore-merger
  - Role: Merge the old repo's comprehensive .gitignore with the local project's .gitignore, ensuring all necessary patterns are included
  - Agent Type: general-purpose
  - Resume: false

- Builder
  - Name: docs-merger
  - Role: Merge documentation from old repo (user-facing docs) with local project docs (implementation plans), organizing them properly
  - Agent Type: general-purpose
  - Resume: false

- Builder
  - Name: ci-validator
  - Role: Validate that GitHub Actions workflows reference correct paths for the new project structure, update if needed
  - Agent Type: general-purpose
  - Resume: false

### TD Task Integration

**IMPORTANT**: Team members (builder, validator) use TD MCP tools to track their work. When executing the plan:

1. **Builders must** create TD tasks for their work:
   ```json
   mcp__td-sidecar__td_create_issue({
     "title": "Task title from plan",
     "type": "task",
     "priority": "P1",
     "description": "Detailed description with acceptance criteria"
   })
   ```

2. **Track progress** using:
   ```json
   mcp__td-sidecar__td_log_entry({"message": "Progress update"})
   ```

3. **Submit for review** when complete:
   ```json
   mcp__td-sidecar__td_submit_review({"task": "<task-id>"})
   ```

4. **Validators approve** validated work:
   ```json
   mcp__td-sidecar__td_approve_task({"task": "<task-id>"})
   ```

This ensures full traceability from planning -> implementation -> validation.

## Step by Step Tasks

### 1. Clone Old Repository
- **Task ID**: clone-old-repo
- **Depends On**: none
- **Assigned To**: repo-migrator
- **Agent Type**: general-purpose
- **Parallel**: false
- Clone `https://github.com/MoshPitCodes/moshpitcodes.nix.git` to `/tmp/moshpitcodes-nix-old`
- Verify the clone contains all expected files (.github/, docs/, wallpapers/mix/, renovate.json, .rsyncignore, SECRETS.md, README.md, LICENSE, .editorconfig, .gitattributes)

### 2. Merge .gitignore Files
- **Task ID**: merge-gitignore
- **Depends On**: clone-old-repo
- **Assigned To**: gitignore-merger
- **Agent Type**: general-purpose
- **Parallel**: false
- Read old repo `.gitignore` from `/tmp/moshpitcodes-nix-old/.gitignore`
- Read local `.gitignore` from `~/Development/shifttab.nix/.gitignore`
- Create merged `.gitignore` that includes:
  - All NixOS-specific patterns from local (secrets.nix, result, result-*, .direnv/)
  - Editor patterns (.idea/, *.swp, *.swo, *~, .vscode/)
  - OS patterns (.DS_Store, Thumbs.db)
  - Build patterns (result, result-*, /build, /dist)
  - Secret patterns (secrets.nix, .env, .env.local)
  - AI/tooling patterns (.opencode/, .todos/, .swarm/, .claude-flow/, node_modules/)
  - `.claude/` should be tracked (remove old exclusion) - the local project has valuable .claude/ configs
  - Keep `secrets.nix` and `secrets.nix.bak` ignored
- Write the merged `.gitignore` to `~/Development/shifttab.nix/.gitignore`

### 3. Copy Old Repo Documentation
- **Task ID**: copy-old-docs
- **Depends On**: clone-old-repo
- **Assigned To**: docs-merger
- **Agent Type**: general-purpose
- **Parallel**: true (can run alongside merge-gitignore)
- Copy old repo docs from `/tmp/moshpitcodes-nix-old/docs/` into `~/Development/shifttab.nix/docs/`
- Specifically copy these files that DON'T exist locally:
  - `docs/README.md`
  - `docs/installation.md`
  - `docs/configuration.md`
  - `docs/development-shells.md`
  - `docs/scripts.md`
  - `docs/wsl.md`
  - `docs/mcp-td-sidecar-integration.md`
  - `docs/templates/` (entire directory)
- DO NOT overwrite existing local docs (migration plans, implementation docs)
- The final docs/ should contain BOTH old user-facing docs AND local implementation docs

### 4. Copy Old Repo Infrastructure Files
- **Task ID**: copy-infrastructure
- **Depends On**: clone-old-repo
- **Assigned To**: repo-migrator
- **Agent Type**: general-purpose
- **Parallel**: true (can run alongside merge-gitignore and copy-old-docs)
- Copy the following from `/tmp/moshpitcodes-nix-old/` to `~/Development/shifttab.nix/`:
  - `.github/` (entire directory - workflows, rulesets, assets, CODEOWNERS, dependabot.yml, PR template)
  - `wallpapers/` (entire directory - replace local .gitkeep-only version with actual wallpaper images)
  - `renovate.json`
  - `.rsyncignore`
  - `SECRETS.md`
  - `README.md`
  - `LICENSE`
  - `.editorconfig`
  - `.gitattributes`
- DO NOT copy: old flake.nix, hosts/, modules/, overlays/, pkgs/, scripts/, shells/, .sidecar/, flake.lock

### 5. Validate CI Workflows
- **Task ID**: validate-ci
- **Depends On**: copy-infrastructure
- **Assigned To**: ci-validator
- **Agent Type**: general-purpose
- **Parallel**: false
- Read `.github/workflows/test-configurations.yml` and `.github/workflows/test-flake.yml`
- Verify workflow references match the new project structure:
  - Check that host names referenced in CI match: desktop, laptop, vm, vmware-guest, wsl
  - Check that flake check commands are correct
  - Check that any path references are still valid
- Update workflows if paths or host names have changed
- Note: The old workflows may reference `--impure` flag which is still needed for secrets.nix

### 6. Initialize Git and Configure Remote
- **Task ID**: init-git
- **Depends On**: merge-gitignore, copy-old-docs, copy-infrastructure
- **Assigned To**: repo-migrator
- **Agent Type**: general-purpose
- **Parallel**: false
- Run `git init` in `~/Development/shifttab.nix/`
- Run `git remote add origin git@github.com:MoshPitCodes/moshpitcodes.nix.git`
- Verify `.gitignore` is properly excluding secrets.nix, .env, swap files, etc.
- Run `git add -A` and review staged files to ensure nothing sensitive is included
- Specifically verify these are NOT staged: secrets.nix, secrets.nix.bak, .secrets.nix.swp, .opencode/, .todos/

### 7. Create Initial Commit and Force Push
- **Task ID**: commit-and-push
- **Depends On**: init-git, validate-ci
- **Assigned To**: repo-migrator
- **Agent Type**: general-purpose
- **Parallel**: false
- Create initial commit: `git commit -m "feat: rewrite NixOS configuration from scratch"`
- With commit body explaining: "Complete rewrite of all NixOS modules and host configurations. Preserved documentation, CI/CD workflows, and project infrastructure from previous repository."
- **IMPORTANT**: Confirm with user before force pushing
- Force push to main: `git push --force origin main`
- Verify push was successful

### 8. Post-Migration Validation
- **Task ID**: validate-all
- **Depends On**: commit-and-push
- **Assigned To**: ci-validator
- **Agent Type**: general-purpose
- **Parallel**: false
- Verify the remote repository at github.com/MoshPitCodes/moshpitcodes.nix shows:
  - New flake.nix and host configurations
  - .github/ directory with workflows and rulesets
  - docs/ directory with both old and new documentation
  - wallpapers/mix/ with actual images
  - renovate.json, .rsyncignore, LICENSE, README.md, SECRETS.md
  - CLAUDE.md (local/new version)
  - .claude/ directory with agents, commands, hooks
- Verify git log shows single clean commit
- Verify GitHub Actions start running (flake check, configuration builds)
- Clean up temporary clone: `rm -rf /tmp/moshpitcodes-nix-old`

### 9. Clean Up Temporary Files
- **Task ID**: cleanup
- **Depends On**: validate-all
- **Assigned To**: repo-migrator
- **Agent Type**: general-purpose
- **Parallel**: false
- Remove temporary clone directory: `rm -rf /tmp/moshpitcodes-nix-old`
- Verify working directory is clean: `git status` shows no untracked files that should be tracked
- Report final status to team lead

## Acceptance Criteria
- [ ] Remote repository contains all new NixOS configurations (flake.nix, hosts/, modules/, overlays/)
- [ ] Remote repository contains .github/ directory with workflows and rulesets from old repo
- [ ] Remote repository contains merged docs/ with both user-facing docs and implementation plans
- [ ] Remote repository contains wallpapers/mix/ with actual wallpaper images
- [ ] Remote repository contains renovate.json, .rsyncignore, LICENSE, .editorconfig, .gitattributes
- [ ] Remote repository contains updated CLAUDE.md (local version)
- [ ] Remote repository contains SECRETS.md from old repo
- [ ] Remote repository contains README.md from old repo
- [ ] Git history is clean (single initial commit)
- [ ] No secrets (secrets.nix, .env) are committed
- [ ] .claude/ directory is tracked in the repository
- [ ] GitHub Actions workflows execute successfully (or at least reference correct paths)

## Validation Commands
Execute these commands to validate the task is complete:

- `git log --oneline` - Should show single initial commit
- `git remote -v` - Should show github.com/MoshPitCodes/moshpitcodes.nix
- `ls .github/workflows/` - Should show test-configurations.yml and test-flake.yml
- `ls .github/rulesets/` - Should show 5 ruleset JSON files
- `ls docs/` - Should show both old docs (installation.md, etc.) and new docs (migration plans)
- `ls wallpapers/mix/` - Should show actual wallpaper image files
- `cat renovate.json | head -5` - Should show Renovate configuration
- `cat .rsyncignore | head -5` - Should show rsync exclusion patterns
- `git status` - Should show clean working tree (no untracked files that should be tracked)
- `grep "secrets.nix" .gitignore` - Should confirm secrets.nix is git-ignored

## Notes
- The old repo's `SECRETS.md` references an `.env`-based approach while the local project uses `secrets.nix`. The SECRETS.md will need updating in a future task to reflect the current approach.
- The old repo's `README.md` may reference files/paths that no longer exist (pkgs/, scripts/, shells/). This should be updated in a future task.
- The `.github/workflows/` may need updates if they reference host configurations that have changed structure. This is handled in Task 5.
- The `.claude/` directory is intentionally tracked (unlike the old repo which ignored it) because it contains valuable agent configurations, commands, and hooks.
- `gh` CLI is not authenticated. The user may need to authenticate (`gh auth login`) or use SSH for the push. The plan assumes SSH (`git@github.com:...`) is configured.
- Force push to main will destroy all 336 commits of history. User has confirmed this is acceptable.
