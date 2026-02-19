# Firefox and Zen Browser configuration
{
  inputs,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    # Zen Browser from flake input (stable versioned release)
    inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".default

    # Media support for Firefox-based browsers
    openh264 # H.264 codec
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav
  ];

  programs.firefox = {
    enable = true;

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
      DRMPlayback = true;
    };

    profiles.default = {
      isDefault = true;
      settings = {
        # Wayland
        "widget.use-xdg-desktop-portal.file-picker" = 1;

        # Privacy
        "browser.send_pings" = false;
        "browser.urlbar.speculativeConnect.enabled" = false;
        "dom.event.clipboardevents.enabled" = false;
        "media.navigator.enabled" = true;
        "network.cookie.cookieBehavior" = 1;
        "network.http.referer.XOriginPolicy" = 2;
        "network.http.referer.XOriginTrimmingPolicy" = 2;

        # Performance
        "gfx.webrender.all" = true;
        "layers.acceleration.force-enabled" = true;

        # Hardware acceleration
        "media.hardware-video-decoding.enabled" = true;
        "media.ffmpeg.vaapi.enabled" = true;

        # DRM support
        "media.eme.enabled" = true;

        # Video playback improvements
        "media.autoplay.default" = 0;
        "media.autoplay.blocking_policy" = 0;
        "media.mediasource.webm.enabled" = true;
        "media.ffvpx.enabled" = true;
        "media.navigator.mediadatadecoder_vpx_enabled" = true;

        # Misc
        "browser.aboutConfig.showWarning" = false;
        "browser.tabs.warnOnClose" = false;
      };
    };
  };

  # Environment variables for hardware acceleration and DRM
  home.sessionVariables = {
    MOZ_USE_XINPUT2 = "1";
    MOZ_WEBRENDER = "1";
    MOZ_ACCELERATED = "1";
  };
}
