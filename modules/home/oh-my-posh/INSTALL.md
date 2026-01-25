# Oh My Posh Installation & Setup Guide

## What Was Done

Your NixOS configuration now has **three Rose Pine themed oh-my-posh prompts** ready to use:

1. **rose-pine** - Original single-line montys-based theme
2. **rose-pine-enhanced** - Extended with additional language/tool segments
3. **rose-pine-modern** - Modern two-line layout (currently active)

## Current Configuration

### Active Theme
**rose-pine-modern** is currently selected in `oh-my-posh.nix`

### Files Created/Modified

```
modules/home/oh-my-posh/
├── oh-my-posh.nix                    (Modified - theme switcher added)
├── rose-pine.omp.toml                (Existing - original theme)
├── rose-pine-enhanced.omp.toml       (New - enhanced theme)
├── rose-pine-modern.omp.toml         (New - modern theme)
├── rose-pine-modern.omp.json         (New - JSON version)
├── README.md                         (New - full documentation)
├── THEMES.md                         (New - visual theme guide)
└── INSTALL.md                        (This file)
```

## How to Apply

### For NixOS with Home Manager Module

```bash
# From your flake directory
cd /home/moshpitcodes/Development/moshpitcodes.nix

# Rebuild your system configuration
sudo nixos-rebuild switch --flake .#your-hostname

# Or if you're on desktop:
sudo nixos-rebuild switch --flake .#desktop

# Or if you're on laptop:
sudo nixos-rebuild switch --flake .#laptop
```

### For Standalone Home Manager

```bash
home-manager switch --flake .#your-username
```

### For WSL

```bash
sudo nixos-rebuild switch --flake .#wsl
```

## Verifying Installation

After rebuilding, restart your terminal or run:

```bash
exec zsh
```

You should see the new oh-my-posh prompt with Rose Pine colors.

### Test oh-my-posh directly

```bash
# Check if oh-my-posh is installed
which oh-my-posh

# View current configuration
oh-my-posh config export

# Test theme rendering
oh-my-posh print primary
```

## Switching Themes

### Quick Switch

Edit `/home/moshpitcodes/Development/moshpitcodes.nix/modules/home/oh-my-posh/oh-my-posh.nix`:

```nix
theme = "rose-pine-modern";  # Change to: "rose-pine" | "rose-pine-enhanced" | "rose-pine-modern"
```

Then rebuild:

```bash
sudo nixos-rebuild switch --flake .#your-hostname
```

### Preview Without Rebuilding

You can test themes without rebuilding by running oh-my-posh directly:

```bash
# Test the modern theme
oh-my-posh init zsh --config ~/Development/moshpitcodes.nix/modules/home/oh-my-posh/rose-pine-modern.omp.toml

# Test the enhanced theme
oh-my-posh init zsh --config ~/Development/moshpitcodes.nix/modules/home/oh-my-posh/rose-pine-enhanced.omp.toml

# Test the original theme
oh-my-posh init zsh --config ~/Development/moshpitcodes.nix/modules/home/oh-my-posh/rose-pine.omp.toml
```

## Font Requirements

All themes use Nerd Font icons. Your configuration already includes these fonts:

- ✅ JetBrains Mono Nerd Font
- ✅ Fira Code Nerd Font
- ✅ Caskaydia Cove Nerd Font
- ✅ Maple Mono NF

Make sure your terminal is configured to use one of these fonts.

### Terminal Font Configuration

#### Ghostty (Your current terminal)
Check `/home/moshpitcodes/Development/moshpitcodes.nix/modules/home/ghostty.nix` and ensure it's using a Nerd Font:

```nix
programs.ghostty = {
  settings = {
    font-family = "Maple Mono NF";  # Or another Nerd Font
    # ...
  };
};
```

## Troubleshooting

### Prompt not changing
1. Make sure you rebuilt the configuration
2. Restart your shell: `exec zsh`
3. Clear zsh cache: `rm -rf ~/.cache/zsh`

### Icons showing as boxes
- Your terminal font is not a Nerd Font
- Change terminal font to one from the list above
- Rebuild configuration after changing font

### Colors look wrong
- Ensure terminal supports true color (24-bit)
- For Ghostty, true color is enabled by default
- Test: `curl -s https://raw.githubusercontent.com/JohnMorales/dotfiles/master/colors/24-bit-color.sh | bash`

### Theme file errors
If you get TOML parsing errors, validate your theme file:

```bash
# Test TOML syntax
nix eval --impure --expr 'builtins.fromTOML (builtins.readFile ./modules/home/oh-my-posh/rose-pine-modern.omp.toml)' --json
```

### Performance issues
If the prompt feels slow:

1. Switch to `rose-pine` (minimal segments)
2. Disable git status fetching in theme file:
   ```toml
   [blocks.segments.properties]
     fetch_status = false
   ```
3. Disable execution time segment

## Additional Customization

### Adding Your Own Segments

See the [oh-my-posh segment documentation](https://ohmyposh.dev/docs/segments/) for all available options.

Example segments you might want to add:
- `aws` - AWS profile and region
- `azure` - Azure subscription
- `terraform` - Terraform workspace
- `dotnet` - .NET version
- `java` - Java version
- `package` - Project package version

### Creating a Custom Theme

1. Copy an existing theme:
   ```bash
   cp modules/home/oh-my-posh/rose-pine-modern.omp.toml modules/home/oh-my-posh/my-custom.omp.toml
   ```

2. Edit the TOML file with your changes

3. Update `oh-my-posh.nix` to include your theme:
   ```nix
   themeFiles = {
     rose-pine = ./rose-pine.omp.toml;
     rose-pine-enhanced = ./rose-pine-enhanced.omp.toml;
     rose-pine-modern = ./rose-pine-modern.omp.toml;
     my-custom = ./my-custom.omp.toml;  # Add this line
   };

   theme = "my-custom";  # Use your custom theme
   ```

4. Rebuild configuration

## Integration with Other Tools

### Starship
Your config has starship disabled (`enable = false` in `modules/home/starship.nix`).
This is correct since you can only use one prompt at a time.

To switch back to starship:
1. Set `programs.oh-my-posh.enable = false` in `oh-my-posh.nix`
2. Set `programs.starship.enable = true` in `starship.nix`
3. Rebuild configuration

### Tmux
oh-my-posh works seamlessly with tmux. No special configuration needed.

### Terminal Multiplexers
The prompt will display correctly in tmux, screen, and zellij.

## Documentation

- 📖 [README.md](./README.md) - Complete feature documentation
- 🎨 [THEMES.md](./THEMES.md) - Visual theme comparison and customization
- 📝 [INSTALL.md](./INSTALL.md) - This file

## Next Steps

1. **Apply the configuration** - Rebuild your NixOS config
2. **Test the prompt** - Restart your terminal
3. **Choose your favorite** - Try all three themes
4. **Customize** - Tweak colors or segments to your preference
5. **Enjoy** - You now have a beautiful, cohesive Rose Pine themed environment!

## Rose Pine Integration

Your entire environment is now Rose Pine themed:

- ✅ **GTK Theme** - rose-pine-gtk-theme
- ✅ **Directory Colors** - vivid rose-pine
- ✅ **Shell Prompt** - oh-my-posh rose-pine themes
- ✅ **Potential**: Terminal colors, editor theme, etc.

For a fully cohesive setup, consider:
- Setting Ghostty/terminal to Rose Pine colors
- Using Rose Pine theme in your editor (VSCode, Neovim, etc.)
- Using Rose Pine for application themes where available

## Support

For issues specific to:
- **oh-my-posh**: https://ohmyposh.dev/docs/
- **Rose Pine**: https://rosepinetheme.com/
- **Nerd Fonts**: https://www.nerdfonts.com/

For NixOS/configuration issues, check your flake configuration.
