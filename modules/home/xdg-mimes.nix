# XDG MIME type associations
{ lib, ... }:
let
  # Default application handlers
  defaultApps = {
    browser = "zen-beta.desktop";
    editor = "org.gnome.TextEditor.desktop";
    image = "imv.desktop";
    video = "mpv.desktop";
    audio = "mpv.desktop";
    filemanager = "org.gnome.Nautilus.desktop";
    pdf = "org.gnome.Evince.desktop";
    archive = "org.gnome.FileRoller.desktop";
    terminal = "com.mitchellh.ghostty.desktop";
  };

  # MIME type to category mapping
  mimeMap = {
    browser = [
      "text/html"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
      "x-scheme-handler/about"
      "x-scheme-handler/unknown"
    ];
    editor = [
      "text/plain"
      "text/x-csrc"
      "text/x-chdr"
      "text/x-python"
      "text/x-shellscript"
      "text/x-makefile"
      "text/x-java"
      "text/x-go"
      "text/x-rust"
      "application/json"
      "application/xml"
      "application/x-yaml"
      "application/toml"
    ];
    image = [
      "image/jpeg"
      "image/png"
      "image/gif"
      "image/webp"
      "image/svg+xml"
      "image/bmp"
      "image/tiff"
    ];
    video = [
      "video/mp4"
      "video/x-matroska"
      "video/webm"
      "video/x-msvideo"
      "video/quicktime"
    ];
    audio = [
      "audio/mpeg"
      "audio/flac"
      "audio/ogg"
      "audio/wav"
      "audio/x-wav"
    ];
    filemanager = [
      "inode/directory"
    ];
    pdf = [
      "application/pdf"
    ];
    archive = [
      "application/zip"
      "application/x-tar"
      "application/gzip"
      "application/x-7z-compressed"
      "application/x-rar-compressed"
    ];
  };

  # Build the associations attrset
  associations = lib.foldlAttrs (
    acc: category: mimeTypes:
    acc // lib.genAttrs mimeTypes (_: [ (defaultApps.${category}) ])
  ) { } mimeMap;
in
{
  xdg.mimeApps = {
    enable = true;
    defaultApplications = associations // {
      # CKAN URL handler for Kerbal Space Program mod manager
      "x-scheme-handler/ckan" = [ "ckan.desktop" ];
    };
  };

  # Prevent Wine from hijacking file associations
  home.sessionVariables.WINEDLLOVERRIDES = "winemenubuilder.exe=d";
}
