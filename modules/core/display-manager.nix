# Display manager configuration (auto-login with hyprlock)
{
  pkgs,
  lib,
  username,
  ...
}:
{
  # Auto-login to Hyprland (hyprlock will handle authentication)
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.hyprland}/bin/start-hyprland";
        user = username;
      };
    };
  };

  # Console configuration
  console = {
    keyMap = "de";
    font = "ter-v32n";
    packages = with pkgs; [ terminus_font ];
  };
}
