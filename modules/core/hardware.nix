# Hardware configuration (graphics, firmware, bluetooth)
{ pkgs, lib, ... }:
{
  hardware = {
    graphics = {
      enable = lib.mkDefault true;
      enable32Bit = lib.mkDefault true;

      # Intel Xe VAAPI drivers - unused on VMware, essential on bare metal
      extraPackages = with pkgs; [
        intel-media-driver # Modern VAAPI driver for Gen8+ (incl. Xe)
        libva-utils # Useful for checking VAAPI status (vainfo)
      ];
    };

    enableRedistributableFirmware = true;

    bluetooth.enable = lib.mkDefault true;
  };
}
