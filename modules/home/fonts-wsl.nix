{ pkgs, ... }:
{
  # WSL-specific font configuration
  # Focused on terminal and development fonts without desktop dependencies

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    # Nerd Fonts - Essential for terminal icons and powerline
    nerd-fonts.jetbrains-mono # Popular monospace font with excellent ligatures
    nerd-fonts.fira-code # Another excellent code font with ligatures
    nerd-fonts.caskaydia-cove # Cascadia Code with Nerd Font patches
    nerd-fonts.symbols-only # CRITICAL: Nerd Font symbols for icons in terminal

    # Emoji support for better terminal experience
    noto-fonts-color-emoji # Google's emoji font

    # Additional monospace fonts
    maple-mono.NF # Maple Mono with Nerd Font patches
    fantasque-sans-mono # Quirky but readable monospace font

    # Optional: Uncomment if you have MonoLisa installed in Nix store
    # monolisa
    # monolisa-nerd
  ];
}
