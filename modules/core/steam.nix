# Steam + Gamescope gaming configuration
{ pkgs, config, ... }:
{
  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = false;
      gamescopeSession.enable = false; # Disabled - can cause launch issues
      extraCompatPackages = [ pkgs.proton-ge-bin ];

      # Use native Steam runtime instead of container
      # This fixes driver access issues on NixOS
      package = pkgs.steam.override {
        extraEnv = {
          # Disable pressure-vessel container runtime
          STEAM_RUNTIME_PREFER_HOST_LIBRARIES = "1";
        };
      };

      # Fix pressure-vessel container driver access on NixOS
      extraPackages = with pkgs; [
        # X11 libraries
        xorg.libXcursor
        xorg.libXi
        xorg.libXinerama
        xorg.libXScrnSaver
        xorg.libXrandr
        xorg.libXrender
        xorg.libX11
        xorg.libXext
        xorg.libXfixes

        # Graphics/OpenGL - including NVIDIA drivers for container
        libGL
        libGLU
        mesa
        vulkan-loader
        vulkan-validation-layers
        config.boot.kernelPackages.nvidiaPackages.production
        libva
        libva-utils

        # Audio
        libpng
        libpulseaudio
        libvorbis
        alsa-lib
        openal

        # System libraries
        stdenv.cc.cc.lib
        libkrb5
        keyutils
        zlib
        dbus
        glib

        # Additional dependencies for X4 Foundations
        fontconfig
        freetype
        gtk3
        pango
        cairo
        gdk-pixbuf
        atk

        # FFmpeg libraries (X4 needs specific versions)
        ffmpeg-full

        # SDL2 and LuaJIT
        SDL2
        luajit
      ];
    };

    gamescope = {
      enable = false; # Disabled for troubleshooting
      capSysNice = true;
      args = [
        "--rt"
        "--expose-wayland"
      ];
    };
  };

  # Environment variables for Steam on NixOS
  environment.sessionVariables = {
    # Help Steam Runtime container find NixOS graphics drivers
    PRESSURE_VESSEL_FILESYSTEMS_RO = "/run/opengl-driver:/run/opengl-driver-32";
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";

    # Disable Steam overlay to prevent LD_PRELOAD errors
    DISABLE_STEAM_OVERLAY = "1";

    # Additional compatibility fixes
    PROTON_ENABLE_NVAPI = "1"; # Enable NVIDIA-specific Proton features
    DXVK_ASYNC = "1"; # Async shader compilation for better performance
  };
}
#
# TROUBLESHOOTING STEAM GAMES NOT LAUNCHING:
#
# Try these launch options in Steam (Right-click game → Properties → Launch Options):
#
# Option 1 - Unset SDL_VIDEODRIVER (fixes Easy AntiCheat & many launcher issues):
#   env --unset=SDL_VIDEODRIVER %command%
#
# Option 2 - Disable overlay:
#   LD_PRELOAD= %command%
#
# Option 3 - Combine both fixes:
#   env --unset=SDL_VIDEODRIVER LD_PRELOAD= %command%
#
# Option 4 - Force Proton GE (if you have it installed):
#   Select "Proton GE" from compatibility tool dropdown instead of Proton Experimental
#
# Option 5 - Use specific Proton version:
#   Try different Proton versions (8.0, 9.0, Experimental) from the dropdown
#
# Option 6 - Enable verbose logging:
#   PROTON_LOG=1 %command%
#   (Then check ~/steam-*.log for detailed errors)
#
# Nuclear option - Reset Steam data (backup first!):
#   mv ~/.local/share/Steam ~/.local/share/Steam.backup
#   Then restart Steam
