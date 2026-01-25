{ pkgs, ... }:

{
  hardware = {
    # Use the modern graphics module.
    # This implicitly selects Mesa (iris/anv) and modesetting drivers for Intel Xe.
    graphics = {
      enable = true;
      enable32Bit = true; # Keep for compatibility (Steam, Wine etc)

      # Do NOT pin Mesa unless you have a specific reason (`package = hyprland-pkgs.mesa;` removed)

      # Add necessary extra packages for Intel Xe features
      extraPackages = with pkgs; [
        intel-media-driver # Modern VAAPI driver for Gen8+ (incl. Xe) - ESSENTIAL for video accel
        # intel-compute-runtime # Optional: Add if you need OpenCL support
        libva-utils # Optional: Useful for checking VAAPI status (vainfo)
        # intel-graphics-compiler # Optional: Usually pulled in automatically if needed
        vaapi-intel-hybrid
      ];

      # If using VAAPI with 32-bit applications (e.g., 32-bit Wine builds)
      # extraPackages32 = with pkgs; [
      #   driversi686.intel-media-driver
      # ];
    };

    # Firmware is essential
    enableRedistributableFirmware = true;

    bluetooth.enable = true;
  };
}
