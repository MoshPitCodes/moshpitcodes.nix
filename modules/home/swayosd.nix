# SwayOSD on-screen display configuration (TokyoNight Storm theme)
{ pkgs, ... }:
{
  home.packages = [ pkgs.swayosd ];

  # SwayOSD service
  systemd.user.services.swayosd = {
    Unit = {
      Description = "SwayOSD on-screen display";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.swayosd}/bin/swayosd-server";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # TokyoNight Storm SwayOSD styling
  xdg.configFile."swayosd/style.css".text = ''
    @define-color background-color #24283b;
    @define-color border-color #c0caf5;
    @define-color label #c0caf5;
    @define-color image #c0caf5;
    @define-color progress #c0caf5;
  '';
}
