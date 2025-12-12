{
  inputs,
  pkgs,
  ...
}:
{
  home.packages =
    with pkgs;
    [
      # inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".default
      inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".twilight-official
      # firefox
      # pkgs.librewolf

      # Add media support for Firefox-based browsers
      gst_all_1.gstreamer
      gst_all_1.gst-plugins-base
      gst_all_1.gst-plugins-good
      gst_all_1.gst-plugins-bad
      gst_all_1.gst-plugins-ugly
      gst_all_1.gst-libav
    ];

  # Firefox/Zen Browser configuration
  programs.firefox = {
    # enable = true;
    # Correct syntax for Firefox policies
    policies = {
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
      OverrideFirstRunPage = "";
      OverridePostUpdatePage = "";
      # Enable DRM support
      DRMPlayback = true;
    };

    # Correct structure for Firefox preferences
    profiles = {
      default = {
        id = 0;
        name = "Default";
        isDefault = true;
        settings = {
          # Enable hardware acceleration
          "media.hardware-video-decoding.enabled" = true;
          "media.ffmpeg.vaapi.enabled" = true;

          # Enable DRM
          "media.eme.enabled" = true;

          # Improve video playback
          "media.autoplay.default" = 0;
          "media.autoplay.blocking_policy" = 0;

          # Support various media formats
          "media.mediasource.webm.enabled" = true;

          # Performance improvements
          "media.ffvpx.enabled" = true;
          "media.navigator.mediadatadecoder_vpx_enabled" = true;
        };
      };
    };
  };

  # Set some environment variables that might help with hardware acceleration and DRM
  home.sessionVariables = {
    MOZ_USE_XINPUT2 = "1";
    MOZ_WEBRENDER = "1";
    MOZ_ACCELERATED = "1";
  };
}
