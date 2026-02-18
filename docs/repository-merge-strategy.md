# Repository Merge Strategy: moshpitcodes.nix → shifttab.nix

## Executive Summary

This document outlines the strategy to merge the old repository (`moshpitcodes.nix`) into the current repository (`shifttab.nix`), preserving relevant files and git history while eliminating development/migration artifacts.

---

## Current State Analysis

### Old Repository (moshpitcodes.nix)
- **Location:** `https://github.com/MoshPitCodes/moshpitcodes.nix`
- **Status:** Production-ready, complete configuration
- **Git History:** Preserved (latest commit: `0f4f5bf`)
- **Key Features:**
  - Complete NixOS configuration for 5 hosts (desktop, laptop, vm, vmware-guest, wsl)
  - Comprehensive documentation
  - CI/CD with GitHub Actions
  - Git repository rulesets and governance
  - Production secrets management
  - Complete module ecosystem (51 home modules)

### Current Repository (shifttab.nix)
- **Location:** `/home/moshpitcodes/Development/shifttab.nix`
- **Status:** Development/migration workspace (NOT a git repository)
- **Key Features:**
  - Active development configuration (57 home modules)
  - Migration documentation and notes
  - Claude Code configuration (`.claude/` directory)
  - Work-in-progress features
  - Missing: vm and wsl hosts

---

## Repository Comparison

### Hosts Configuration

| Host | Old Repo | Current Repo | Action |
|------|----------|--------------|--------|
| desktop | ✅ | ✅ | Keep current (has latest changes) |
| laptop | ✅ | ✅ | Keep current (has latest changes) |
| vmware-guest | ✅ | ✅ | Keep current |
| vm | ✅ | ❌ | **Import from old** |
| wsl | ✅ | ❌ | **Import from old** |

### Home Modules Differences

**Only in OLD repo (need review):**
- `aseprite` - Pixel art editor
- `gtk.nix` - GTK theming (replaced by `theming.nix`)
- `nemo.nix` - File manager (replaced by Nautilus)
- `oh-my-posh/` - Shell prompt (replaced by Starship)
- `rofi.nix` - App launcher (replaced by Walker)
- `swaync/` - Directory version (current has `swaync.nix`)
- `tmux/` - Directory version (current has `tmux.nix`)
- `unity.nix` - Game engine IDE

**Only in CURRENT repo (keep):**
- `default.desktop.nix` - Desktop-specific overrides
- `default.laptop.nix` - Laptop-specific overrides
- `hypridle.nix` - Idle management
- `hyprlock.nix` - Lock screen
- `hyprpaper.nix` - Wallpaper management
- `language-servers.nix` - LSP configuration
- `media.nix` - Media applications
- `sidecar.nix` - Sidecar/TD integration
- `starship.toml` - Shell prompt config
- `theming.nix` - Modern theming
- `walker.nix` - Modern app launcher
- `wlogout.nix` - Logout menu

### Documentation

**Old Repo (production docs - KEEP):**
- `configuration.md` - System configuration guide
- `development-shells.md` - Dev environments
- `installation.md` - Installation guide
- `scripts.md` - Script documentation
- `wsl.md` - WSL setup guide
- `README.md` - Main documentation
- `SECRETS.md` - Secrets management
- `templates/` - Document templates

**Current Repo (migration notes - ARCHIVE):**
- `add-default-apps-and-config.md` - Migration note
- `adopt-maciejonos-dotfiles.md` - Migration note
- `create-laptop-host-config.md` - Migration note
- `implement-desktop-host.md` - Migration note
- `implement-ml4w-tools-and-visuals.md` - Migration note
- `migrate-*.md` - Migration notes (multiple)
- `packaging-sidecar-and-td.md` - Implementation note
- `language-servers.md` - Keep (new content)
- `nas-mount-template.nix` - Keep (template)

### GitHub Configuration

**Old Repo (CRITICAL - PRESERVE):**
- `.github/workflows/` - CI/CD pipelines
- `.github/rulesets/` - Repository protection rules
- `.github/CODEOWNERS` - Code ownership
- `.github/dependabot.yml` - Dependency automation
- `.github/pull_request_template.md` - PR template
- `.github/assets/` - Screenshots, logos, badges

**Current Repo:**
- None (needs GitHub config)

### Other Critical Files

| File | Old Repo | Current Repo | Decision |
|------|----------|--------------|----------|
| `flake.nix` | ✅ Production | ✅ Modified | **Merge carefully** |
| `flake.lock` | ✅ Stable | ✅ Current | Keep current (newer) |
| `.gitignore` | ✅ Complete | ✅ Partial | Use old repo version |
| `CLAUDE.md` | ✅ | ✅ | **Merge** (current has updates) |
| `README.md` | ✅ Professional | ❌ | Use old repo version |
| `LICENSE` | ✅ MIT | ❌ | Use old repo version |
| `treefmt.toml` | ✅ | ✅ | Use current (identical) |
| `.editorconfig` | ✅ | ❌ | Import from old |
| `.gitattributes` | ✅ | ❌ | Import from old |
| `.rsyncignore` | ✅ | ❌ | Import from old |
| `renovate.json` | ✅ | ❌ | Import from old |

---

## Merge Strategy

### Option 1: Git History Preservation (RECOMMENDED)

**Approach:** Preserve full git history from old repo, add new changes as commits on top.

**Steps:**

1. **Backup current work**
   ```bash
   cd /home/moshpitcodes/Development
   cp -r shifttab.nix shifttab.nix.backup
   ```

2. **Clone old repository with full history**
   ```bash
   cd /home/moshpitcodes/Development
   git clone git@github.com:MoshPitCodes/moshpitcodes.nix moshpitcodes-merged
   cd moshpitcodes-merged
   ```

3. **Create migration branch**
   ```bash
   git checkout -b migrate-from-shifttab
   ```

4. **Import missing VM and WSL hosts** (if needed)
   - Already present in old repo, verify they're current

5. **Selectively merge new features from shifttab.nix**

   a. **Copy new/updated home modules:**
   ```bash
   # Copy new modules not in old repo
   cp ../shifttab.nix/modules/home/hypridle.nix modules/home/
   cp ../shifttab.nix/modules/home/hyprlock.nix modules/home/
   cp ../shifttab.nix/modules/home/hyprpaper.nix modules/home/
   cp ../shifttab.nix/modules/home/language-servers.nix modules/home/
   cp ../shifttab.nix/modules/home/media.nix modules/home/
   cp ../shifttab.nix/modules/home/sidecar.nix modules/home/
   cp ../shifttab.nix/modules/home/theming.nix modules/home/
   cp ../shifttab.nix/modules/home/walker.nix modules/home/
   cp ../shifttab.nix/modules/home/wlogout.nix modules/home/

   # Copy updated modules
   cp -r ../shifttab.nix/modules/home/discord modules/home/
   cp -r ../shifttab.nix/modules/home/hyprland modules/home/
   # ... (repeat for other updated modules)
   ```

   b. **Update flake.nix with new inputs** (merge carefully):
   - Compare both flake.nix files
   - Add any missing inputs from shifttab.nix
   - Preserve old repo's structure and defaults

   c. **Update CLAUDE.md**:
   ```bash
   # Merge CLAUDE.md files (current has updates)
   cp ../shifttab.nix/CLAUDE.md CLAUDE.md
   ```

   d. **Archive migration docs**:
   ```bash
   mkdir -p docs/archive/migration-notes
   cp ../shifttab.nix/docs/migrate-*.md docs/archive/migration-notes/
   cp ../shifttab.nix/docs/implement-*.md docs/archive/migration-notes/
   cp ../shifttab.nix/docs/adopt-*.md docs/archive/migration-notes/
   ```

   e. **Keep useful new docs**:
   ```bash
   cp ../shifttab.nix/docs/language-servers.md docs/
   cp ../shifttab.nix/docs/nas-mount-template.nix docs/
   ```

6. **Update host configurations**
   ```bash
   # Replace with latest versions from shifttab.nix
   cp -r ../shifttab.nix/hosts/desktop hosts/
   cp -r ../shifttab.nix/hosts/laptop hosts/
   cp -r ../shifttab.nix/hosts/vmware-guest hosts/
   ```

7. **Test build**
   ```bash
   nix flake check
   nix build .#nixosConfigurations.desktop.config.system.build.toplevel
   ```

8. **Commit changes**
   ```bash
   git add .
   git commit -m "feat: merge improvements from shifttab.nix development

   - Add new home modules (hypridle, hyprlock, hyprpaper, walker, wlogout)
   - Update Hyprland configuration with latest keybindings
   - Improve language server configuration
   - Update Discord module (remove DiscoCSS)
   - Archive migration documentation
   - Update CLAUDE.md with latest instructions

   Merged from shifttab.nix development branch"
   ```

9. **Push and create PR**
   ```bash
   git push origin migrate-from-shifttab
   # Create PR on GitHub
   ```

10. **After PR approval, rename repository**
    - On GitHub: Settings → General → Repository name → Change to desired name
    - Update local remote: `git remote set-url origin <new-url>`

### Option 2: Fresh Start (NOT RECOMMENDED)

**Pros:** Clean slate, no history baggage
**Cons:** **Lose all git history, CI/CD, GitHub config, issues, PRs**

---

## Recommended Approach: Option 1 with Cleanup

1. Use Option 1 to preserve history
2. After merge, clean up unnecessary files:
   - Archive migration docs to `docs/archive/`
   - Remove `.claude/` from git (add to .gitignore)
   - Remove `.todos/` from git
   - Remove `.opencode/` from git
   - Clean up any swap files (.swp)

3. Maintain git hygiene:
   - Keep GitHub Actions workflows
   - Keep repository rulesets
   - Keep CODEOWNERS
   - Keep all production documentation

---

## Files/Directories to Handle

### DELETE from merged repo:
```
.claude/               # Claude Code local config (git-ignored)
.opencode/            # OpenCode local config (git-ignored)
.todos/               # Local task management (git-ignored)
*.swp                 # Vim swap files
secrets.nix.bak       # Backup file
docs/migrate-*.md     # Migration notes → archive
docs/implement-*.md   # Implementation notes → archive
docs/adopt-*.md       # Adoption notes → archive
docs/sync-*.md        # Sync notes → archive
```

### KEEP from old repo:
```
.github/              # All GitHub configuration
docs/                 # Production documentation
scripts/              # System scripts
pkgs/                 # Custom packages
overlays/             # Package overlays
shells/               # Dev shells
wallpapers/           # Wallpaper assets
hosts/vm/             # VM configuration
hosts/wsl/            # WSL configuration
README.md             # Main documentation
LICENSE               # MIT license
.editorconfig         # Editor config
.gitattributes        # Git attributes
.rsyncignore          # Rsync ignore patterns
renovate.json         # Dependency automation
```

### MERGE carefully:
```
flake.nix             # Combine inputs, preserve structure
CLAUDE.md             # Merge project-specific instructions
modules/home/         # Combine module sets
hosts/desktop/        # Use newer version
hosts/laptop/         # Use newer version
hosts/vmware-guest/   # Use newer version
```

---

## Risk Mitigation

### Risks:

1. **Breaking builds** - Old configs might not build with current state
   - Mitigation: Test each host configuration before final commit

2. **Losing current work** - Current shifttab.nix has active development
   - Mitigation: Full backup before starting, commit in small chunks

3. **Module conflicts** - Different versions of same module
   - Mitigation: Careful file-by-file review, test after each module merge

4. **Secret exposure** - Accidentally committing secrets
   - Mitigation: Verify .gitignore before first commit, review all files

5. **Git history pollution** - Messy commit history
   - Mitigation: Use meaningful commit messages, squash if needed

### Pre-merge Checklist:

- [ ] Backup shifttab.nix directory
- [ ] Clone fresh copy of old repo
- [ ] Review all files being merged
- [ ] Test flake.nix builds
- [ ] Verify .gitignore excludes secrets
- [ ] Check all host configurations build
- [ ] Review GitHub Actions still work
- [ ] Update documentation references

---

## Post-Merge Tasks

1. **Update repository name** (if desired)
   - GitHub Settings → Rename repository
   - Update flake.nix `description`
   - Update README.md title

2. **Update secrets.nix.example** if format changed

3. **Run full CI/CD pipeline** to verify builds

4. **Update local clones**:
   ```bash
   cd /home/moshpitcodes/Development
   rm -rf shifttab.nix.backup  # After confirming merge successful
   ```

5. **Close any migration-related issues**

6. **Archive shifttab.nix** if it was a temporary workspace

---

## Timeline Estimate

| Phase | Duration | Description |
|-------|----------|-------------|
| Backup | 5 min | Backup current work |
| Clone & Setup | 10 min | Clone old repo, create branch |
| Module Merge | 1-2 hours | Carefully merge home modules |
| Host Config Update | 30 min | Update host configurations |
| Flake Merge | 30 min | Merge flake.nix inputs/outputs |
| Documentation | 30 min | Merge docs, archive migration notes |
| Testing | 1 hour | Build all configurations |
| Commit & Push | 15 min | Create meaningful commits |
| **Total** | **3-4 hours** | Full merge with testing |

---

## Conclusion

**Recommended Action:** Use **Option 1 (Git History Preservation)** to maintain the production repository's integrity while incorporating improvements from the shifttab.nix development workspace.

The merge should be done carefully, testing each phase to ensure no breaking changes are introduced. The old repository's structure, documentation, and CI/CD should be preserved as the foundation, with selective additions from the current development workspace.

---

**Created:** 2026-02-16
**Last Updated:** 2026-02-16
**Status:** Ready for execution (pending user approval)
