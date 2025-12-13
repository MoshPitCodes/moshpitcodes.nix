{ lib, ... }:
let
  # Available Rose Pine theme variants:
  # - "rose-pine"          : Original montys-based single-line theme
  # - "rose-pine-enhanced" : Enhanced version with additional language/tool segments
  # - "rose-pine-modern"   : Modern two-line layout with right-aligned segments
  # - "rose-pine-hunk"     : Hunk theme with Rose Pine colors (two-line, powerline style)
  theme = "rose-pine-hunk";

  # Theme file mapping (supports both TOML and JSON)
  themeFiles = {
    rose-pine = { file = ./rose-pine.omp.toml; format = "toml"; };
    rose-pine-enhanced = { file = ./rose-pine-enhanced.omp.toml; format = "toml"; };
    rose-pine-modern = { file = ./rose-pine-modern.omp.toml; format = "toml"; };
    rose-pine-hunk = { file = ./rose-pine-hunk.omp.json; format = "json"; };
  };

  selectedTheme = themeFiles.${theme} or (throw "Invalid theme: ${theme}. Available themes: ${builtins.toString (builtins.attrNames themeFiles)}");

  # Parse theme based on format
  parseTheme = themeConfig:
    if themeConfig.format == "json"
    then builtins.fromJSON (builtins.readFile themeConfig.file)
    else builtins.fromTOML (builtins.readFile themeConfig.file);
in
{
  programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = true;
    settings = parseTheme selectedTheme;
  };
}
