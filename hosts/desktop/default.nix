{ pkgs, config, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./../../modules/core
  ];

  boot = {
    plymouth = {
      enable = true;
      theme = "circle_flow";
      themePackages = with pkgs; [
        # By default we would install all themes
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "circle_flow" ];
        })
      ];
    };

    # Enable "Silent boot"
    consoleLogLevel = 3;
    initrd = {
      verbose = false;
      kernelModules = [
        "i915" # For Intel GPU support
      ];
    };

    # Hide the OS choice for bootloaders.
    # It's still possible to open the bootloader list by pressing any key
    # It will just not appear on screen unless a key is pressed
    loader.timeout = 0;

    kernelModules = [
      "acpi_call" # For ACPI calls
      "btusb" # For Bluetooth
      "coretemp" # For CPU temperature monitoring
      "hid_multitouch" # For touchscreen/trackpad
      "intel_pstate"
      "intel_rapl" # For Intel RAPL (Running Average Power Limit)
      "intel_rapl_perf" # For Intel RAPL performance
      # "intel_rapl_perf_msr" # For Intel RAPL performance MSR
      "iwlwifi" # For Intel WiFi
      "kvm-intel"
      "msr" # For CPU registers access
      "snd_hda_intel" # Audio support
      # "xfs" # If using XFS filesystem

    ];

    extraModulePackages = with config.boot.kernelPackages; [
      # Any out-of-tree modules you might need
    ];

    kernelParams = [
      "intel_pstate=active" # Performance mode for Intel CPUs
      "mitigations=off" # Disable CPU security mitigations for performance (security risk!)
      "threadirqs" # Threading for IRQs to improve responsiveness
      "nowatchdog" # Disable watchdog for slight performance improvement

      "quiet" # Suppress kernel messages
      "splash" # Enable splash screen
      "boot.shell_on_fail" # Drop to shell on boot failure
      "udev.log_priority=3" # Set udev log level to 3 (error)
      "rd.systemd.show_status=auto" # Show systemd status messages
    ];

    kernel.sysctl = {
      "vm.swappiness" = 10; # Reduce swap usage
      "vm.dirty_ratio" = 60; # Allow more dirty pages in memory
      "vm.dirty_background_ratio" = 30; # Start writing dirty pages at this threshold
      "kernel.sched_autogroup_enabled" = 0; # Disable autogroup for better desktop scheduling
    };

  };
}
