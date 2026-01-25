# Oh My Posh - Rose Pine Themes

This directory contains custom oh-my-posh themes styled with the Rose Pine color palette.

## Rose Pine Color Palette

```
Base:    #191724  (Dark background)
Surface: #1f1d2e  (Slightly lighter background)
Overlay: #26233a  (UI element background)
Muted:   #6e6a86  (Muted/inactive text)
Subtle:  #908caa  (Subdued text)
Text:    #e0def4  (Primary text)
Love:    #eb6f92  (Red/Pink - errors, important)
Gold:    #f6c177  (Yellow - warnings, attention)
Rose:    #ebbcba  (Light pink - secondary accent)
Pine:    #31748f  (Cyan/Teal - success, primary accent)
Foam:    #9ccfd8  (Light cyan - info, secondary)
Iris:    #c4a7e7  (Purple - tertiary accent)
```

## Available Themes

### 1. `rose-pine` (Original)
**File:** `rose-pine.omp.toml`

The original single-line powerline theme based on the "montys" oh-my-posh theme.

**Features:**
- Single-line powerline layout
- OS/Hostname indicator
- Full path display
- Git branch and status
- Node.js version
- Execution time
- Current time
- Exit status indicator
- Username prompt on second line

**Best for:** Users who prefer a detailed single-line prompt with comprehensive information.

### 2. `rose-pine-enhanced` (Extended)
**File:** `rose-pine-enhanced.omp.toml`

An enhanced version of the original with additional language and tool segments.

**Features:**
- All features from the original theme
- Python environment and version
- Go version
- Rust version
- Docker context
- Kubernetes context
- Nix shell indicator
- Battery status (useful for laptops)

**Best for:** Developers working with multiple programming languages and cloud tools.

### 3. `rose-pine-modern` (Recommended)
**File:** `rose-pine-modern.omp.toml` / `rose-pine-modern.omp.json`

A modern two-line layout with left and right-aligned segments, based on the "bubblesline" design.

**Features:**
- **Left side:**
  - OS indicator (with WSL detection)
  - Full path
  - Node.js version (when detected)
  - Python version and venv (when detected)
  - Git status with dynamic colors:
    - Cyan (foam): Clean repository
    - Yellow (gold): Uncommitted changes
    - Purple (iris): Diverged from upstream
    - Teal (pine): Ahead of upstream
    - Pink (love): Behind upstream
- **Right side:**
  - Execution time
  - Root indicator (⚡ when running as root)
  - Username
  - Shell name
- **New line:**
  - Clean prompt character (›)

**Best for:** Modern, clean interface with important information clearly separated.

## Switching Themes

To switch between themes, edit the `theme` variable in `oh-my-posh.nix`:

```nix
theme = "rose-pine-modern";  # Change this to your preferred theme
```

Options:
- `"rose-pine"` - Original single-line theme
- `"rose-pine-enhanced"` - Enhanced with more segments
- `"rose-pine-modern"` - Modern two-line layout (recommended)

After changing the theme, rebuild your NixOS/Home Manager configuration:

```bash
# For NixOS system
sudo nixos-rebuild switch

# For Home Manager standalone
home-manager switch

# For Home Manager as NixOS module (depends on your setup)
sudo nixos-rebuild switch --flake .#your-hostname
```

## Customization

Each theme file can be customized to add/remove segments or change colors. The theme files are in TOML format (or JSON for `rose-pine-modern.omp.json`).

### Adding New Segments

Refer to the [oh-my-posh segment documentation](https://ohmyposh.dev/docs/segments/) for all available segments.

### Color Modifications

All colors in the themes follow the Rose Pine palette. If you want to adjust colors, reference the palette above or the [Rose Pine specification](https://rosepinetheme.com/palette).

## Font Requirements

These themes use Nerd Font icons. Ensure you have a Nerd Font installed. Your configuration already includes:
- JetBrains Mono Nerd Font
- Fira Code Nerd Font
- Caskaydia Cove Nerd Font
- Maple Mono NF

## Integration

oh-my-posh is integrated with zsh via Home Manager:

```nix
programs.oh-my-posh = {
  enable = true;
  enableZshIntegration = true;
  settings = builtins.fromTOML (builtins.readFile selectedThemeFile);
};
```

The integration ensures the prompt is automatically loaded when you start a zsh session.

## Theme Comparison

| Feature | rose-pine | rose-pine-enhanced | rose-pine-modern |
|---------|-----------|-------------------|------------------|
| Layout | Single-line | Single-line | Two-line |
| Path | Full | Full | Full |
| Git | ✓ | ✓ | ✓ (with dynamic colors) |
| Node.js | ✓ | ✓ | ✓ |
| Python | ✗ | ✓ | ✓ |
| Go | ✗ | ✓ | ✗ |
| Rust | ✗ | ✓ | ✗ |
| Docker | ✗ | ✓ | ✗ |
| Kubernetes | ✗ | ✓ | ✗ |
| Battery | ✗ | ✓ | ✗ |
| Time | ✓ | ✓ | ✗ |
| Execution time | ✓ | ✓ | ✓ |
| Right-aligned info | ✗ | ✗ | ✓ |
| Best for | Classic look | Multi-language dev | Clean & modern |

## Troubleshooting

### Theme not updating
If the theme doesn't change after editing the config:
1. Ensure you've run `home-manager switch` or `sudo nixos-rebuild switch`
2. Restart your terminal session
3. Check for syntax errors in the TOML file

### Icons not displaying
- Ensure you're using a Nerd Font in your terminal emulator
- Check that your terminal font is set to one of the installed Nerd Fonts

### Colors look wrong
- Ensure your terminal supports true color (24-bit color)
- Some terminal emulators may need true color enabled in settings

## Additional Resources

- [Oh My Posh Documentation](https://ohmyposh.dev/)
- [Rose Pine Theme](https://rosepinetheme.com/)
- [Nerd Fonts](https://www.nerdfonts.com/)
