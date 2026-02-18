# SwayOSD on-screen display configuration (Everforest theme)
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

  # Everforest SwayOSD styling
  xdg.configFile."swayosd/style.css".text = ''
    @define-color background-color #2d353b;
    @define-color border-color #d3c6aa;
    @define-color label #d3c6aa;
    @define-color image #d3c6aa;
    @define-color progress #d3c6aa;
  '';
}
