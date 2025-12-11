{ pkgs, ... }:
{
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.caskaydia-cove
    nerd-fonts.symbols-only
    twemoji-color-font
    noto-fonts-color-emoji
    fantasque-sans-mono
    # monolisa
    # monolisa-nerd
    # maple-mono # do not use anymore
    # maple-mono.CN
    # maple-mono.CN-unhinted
    maple-mono.NF
    # maple-mono.NF-CN
    # maple-mono.NF-CN-unhinted
    # maple-mono.NF-unhinted
    # maple-mono.NL-CN
    # maple-mono.NL-CN-unhinted
    # maple-mono.NL-NF
    # maple-mono.NL-NF-CN
    # maple-mono.NL-NF-CN-unhinted
    # maple-mono.NL-NF-unhinted
    # maple-mono.NL-OTF
    # maple-mono.NL-TTF
    # maple-mono.NL-TTF-AutoHint
    # maple-mono.NL-Variable
    # maple-mono.NL-Woff2
    # maple-mono.Normal-CN
    # maple-mono.Normal-CN-unhinted
    # maple-mono.Normal-NF
    # maple-mono.Normal-NF-CN
    # maple-mono.Normal-NF-CN-unhinted
    # maple-mono.Normal-NF-unhinted
    # maple-mono.Normal-OTF
    # maple-mono.Normal-TTF
    # maple-mono.Normal-TTF-AutoHint
    # maple-mono.Normal-Variable
    # maple-mono.Normal-Woff2
    # maple-mono.NormalNL-CN
    # maple-mono.NormalNL-CN-unhinted
    # maple-mono.NormalNL-NF
    # maple-mono.NormalNL-NF-CN
    # maple-mono.NormalNL-NF-CN-unhinted
    # maple-mono.NormalNL-NF-unhinted
    # maple-mono.NormalNL-OTF
    # maple-mono.NormalNL-TTF
    # maple-mono.NormalNL-TTF-AutoHint
    # maple-mono.NormalNL-Variable
    # maple-mono.NormalNL-Woff2
    # maple-mono.opentype
    # maple-mono.override
    # maple-mono.overrideDerivation
    # maple-mono.recurseForDerivations
    # maple-mono.truetype
    # maple-mono.truetype-autohint
    # maple-mono.variable
    # maple-mono.woff2
  ];
  # ++ (lib.attrValues pkgs.maple-mono);

  gtk = {
    enable = true;
    font = {
      name = "Maple Mono NF";
      size = 12;
    };
    theme = {
      name = "rose-pine";
      package = pkgs.rose-pine-gtk-theme;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme.override { color = "black"; };
    };
    cursorTheme = {
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
      size = 24;
    };
  };

  home.pointerCursor = {
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 24;
  };
}
