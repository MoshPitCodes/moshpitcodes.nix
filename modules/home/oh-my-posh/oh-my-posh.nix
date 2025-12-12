{ ... }:
{
  programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = true;
    useTheme = "rose-pine";
  };

  xdg.configFile."oh-my-posh/themes/rose-pine.omp.json".source = ./rose-pine.omp.json;
}
