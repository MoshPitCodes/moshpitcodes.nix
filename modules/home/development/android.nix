# Android development and ROM flashing tools
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Android SDK Platform Tools (ADB + Fastboot)
    # Note: programs.adb.enable in core/program.nix handles udev rules
    android-tools

    # Android development
    android-studio

    # Device screen mirroring/control over ADB
    scrcpy

    # Samsung-specific ROM flashing (Odin alternative for Linux)
    heimdall
  ];
}
