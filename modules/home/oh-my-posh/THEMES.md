# Oh My Posh Rose Pine Theme Gallery

Visual guide to the available Rose Pine themed oh-my-posh prompts.

## Theme Previews

### rose-pine (Original)

**Layout:** Single-line powerline with second line for prompt

```
 NixOS hostname  ~/path/to/directory  ➜ (main)  󰔛 245ms  3:04 PM
 ⚡moshpitcodes ⯯⯯
```

**Color breakdown:**
- 󰌽 OS/Host: Overlay background (#26233a) + Pine text (#31748f)
- 📁 Path: Love background (#eb6f92) + White text
- 🔀 Git: Rose background (#ebbcba) + Base text (#191724)
- ⏱ Time: Foam background (#9ccfd8) + Base text
- ✓ Status: Pine background (#31748f), or Love (#eb6f92) on error

---

### rose-pine-enhanced (Extended)

**Layout:** Single-line powerline with all language segments

```
 NixOS hostname  ~/path  ➜ (main)  3.11.5  v20.11.0  󰔛 245ms  󰁹 85%  3:04 PM
 ⚡moshpitcodes ⯯⯯
```

**Added segments:**
-  Python: Gold background (#f6c177)
-  Go: Foam background (#9ccfd8)
-  Rust: Love background (#eb6f92)
-  Docker: Subtle background (#908caa)
- 󱃾 Kubernetes: Iris background (#c4a7e7)
- 󰁹 Battery: Dynamic (Gold/Love/Pine based on level)

---

### rose-pine-modern (Recommended - Two-line)

**Layout:** Modern two-line with left/right alignment

```
 NixOS  ~/Development/moshpitcodes.nix   v20.11.0  3.11.5  main  󰔛 245ms  moshpitcodes  zsh

```

**Left side (primary info):**
- 󰌽 OS: Love background (#eb6f92) + Text (#e0def4)
- 📁 Path: Love background (#eb6f92) + Text
-  Node: Rose background (#ebbcba) + Text
-  Python: Rose background (#ebbcba) + Text
-  Git: Dynamic background based on status
  - Clean: Foam (#9ccfd8)
  - Changes: Gold (#f6c177)
  - Diverged: Iris (#c4a7e7)
  - Ahead: Pine (#31748f)
  - Behind: Love (#eb6f92)

**Right side (context info):**
- ⏱ Execution time: Subtle background (#908caa)
- ⚡ Root indicator: Pine background (#31748f) + Gold text (#f6c177)
- 👤 Username: Pine background (#31748f)
- 🐚 Shell: Overlay background (#26233a)

**New line:**
- › Simple prompt character in Foam (#9ccfd8)

---

## Git Status Color Coding

All themes use color-coded git status for quick visual feedback:

| Status | Color | Hex | Meaning |
|--------|-------|-----|---------|
| Clean | Foam | #9ccfd8 | No changes, synced |
| Modified | Gold | #f6c177 | Uncommitted changes |
| Diverged | Iris | #c4a7e7 | Both ahead and behind |
| Ahead | Pine | #31748f | Local commits not pushed |
| Behind | Love | #eb6f92 | Remote commits not pulled |

## Icons Used

These themes use Nerd Font icons. Ensure your terminal font is a Nerd Font.

| Segment | Icon | Unicode | Description |
|---------|------|---------|-------------|
| NixOS | 󰌽 | \ue62a | NixOS logo |
| Folder |  | \uf07b | Directory |
| Git |  | \ue0a0 | Git branch |
| Node.js |  | \ue718 | Node.js logo |
| Python |  | \ue235 | Python logo |
| Go |  | \ue627 | Golang logo |
| Rust |  | \ue7a8 | Rust logo |
| Docker |  | \uf308 | Docker logo |
| Kubernetes | 󱃾 | \ufd31 | Kubernetes logo |
| Time |  | \uf017 | Clock |
| Duration | 󰔛 | \ueba2 | Stopwatch |
| Success |  | \uf469 | Checkmark |
| Error |  | \uf421 | X mark |
| Lightning | ⚡ | \u26a1 | Root/sudo indicator |
| Arrow | › | \u276f | Prompt character |
| Battery | 󰁹 | \uf583 | Battery indicator |

## Quick Start

1. Choose your preferred theme by editing `/home/moshpitcodes/Development/moshpitcodes.nix/modules/home/oh-my-posh/oh-my-posh.nix`:

```nix
theme = "rose-pine-modern";  # or "rose-pine" or "rose-pine-enhanced"
```

2. Rebuild your configuration:

```bash
sudo nixos-rebuild switch --flake .#your-hostname
```

3. Restart your terminal or source your shell:

```bash
exec zsh
```

## Customization Examples

### Change the prompt character

Edit your chosen theme file and modify the text segment:

```toml
# In the newline block
[[blocks.segments]]
  type = "text"
  style = "plain"
  foreground = "#9ccfd8"
  template = "\u276f"  # Change this to any character/icon
```

Popular alternatives:
- `❯` (\u276f) - Current default
- `λ` (\u03bb) - Lambda (functional programming)
- `⮞` (\u2b9e) - Arrow
- `➜` (\u279c) - Bold arrow
- `$` - Traditional shell

### Add a custom segment

Example: Add a Nix shell indicator to `rose-pine-modern.omp.toml`:

```toml
# Add before the git segment
[[blocks.segments]]
  type = "shell"
  style = "powerline"
  powerline_symbol = "\ue0b0"
  background = "#31748f"
  foreground = "#e0def4"
  template = " \uf313 {{ .Name }} "

  [blocks.segments.properties]
    mapped_shell_names = { nix-shell = "nix" }
```

### Adjust path length

In the path segment, modify:

```toml
[blocks.segments.properties]
  style = "folder"  # Options: "full", "folder", "mixed", "agnoster_short"
  max_depth = 3     # Show only last 3 directories
```

## Performance Notes

- **rose-pine**: Fastest, minimal segments
- **rose-pine-enhanced**: Slightly slower due to language version checks
- **rose-pine-modern**: Moderate, only checks detected languages

To improve performance, disable `fetch_status` in git segments if not needed.

## Theme Philosophy

All themes follow Rose Pine's design principles:

1. **Low to medium contrast** - Easy on the eyes during long coding sessions
2. **Pastel colors** - Soft, muted tones that don't strain vision
3. **Semantic color use** - Colors convey meaning (red=error, cyan=info, etc.)
4. **Consistent palette** - All UI elements use the same color scheme

This creates a cohesive, comfortable visual environment across your entire system (GTK, terminal, editors, and now your shell prompt).
