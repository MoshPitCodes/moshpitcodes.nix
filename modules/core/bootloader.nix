# Boot loader configuration
{ pkgs, lib, ... }:
{
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    # Use the latest kernel
    kernelPackages = pkgs.linuxPackages_latest;

    # Common kernel parameters
    kernelParams = [
      "quiet"
      "splash"
    ];

    # Plymouth for boot splash
    plymouth.enable = true;
  };
}
