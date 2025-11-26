{ pkgs, config, username, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./../../modules/core
  ];

  environment.systemPackages = with pkgs; [
    acpi
    brightnessctl
    cpupower-gui
    powertop
  ];

  # allow local remote access to make it easier to toy around with the system
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = false;
      AllowUsers = [ username ];
      PermitRootLogin = "no";
    };
  };
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
        "i915" # For Intel GPU support on boot phase 1
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
      "intel_pstate" # For Intel P-state driver
      "intel_rapl" # For Intel RAPL (Running Average Power Limit)
      "intel_rapl_perf" # For Intel RAPL performance
      "iwlwifi" # For Intel WiFi
      "kvm-intel" # For KVM virtualization
      "msr" # For CPU registers access
      "snd_hda_intel" # Audio support
      # "intel_rapl_perf_msr" # For Intel RAPL performance MSR
    ];
    extraModulePackages =
      with config.boot.kernelPackages;
      [
        cpupower
      ]
      ++ [ pkgs.cpupower-gui ];
    kernelParams = [
      "i915.force_probe=a7a0"
      "intel_pstate=active" # Performance mode for Intel CPUs
      "threadirqs" # Threading for IRQs to improve responsiveness
      "nowatchdog" # Disable watchdog for slight performance improvement

      "nvme.noacpi=1" # Can help with NVMe performance

      "quiet" # Suppress kernel messages
      "splash" # Enable splash screen
      "boot.shell_on_fail" # Drop to shell on boot failure
      "udev.log_priority=3" # Set udev log level to 3 (error)
      "rd.systemd.show_status=auto" # Show systemd status messages

      # "mitigations=off" # Disable CPU security mitigations for performance (security risk!)
      # "i915.enable_fbc=1" # Frame buffer compression for power saving
      # "i915.enable_psr=2" # Panel self-refresh for power saving
    ];
    # Add the kernel sysctl parameters
    kernel.sysctl = {
      "vm.swappiness" = 10; # Reduce swap usage
      "vm.vfs_cache_pressure" = 50; # Better file caching
      "vm.dirty_background_ratio" = 30; # Start writing dirty pages at this threshold
      "kernel.sched_autogroup_enabled" = 0; # Disable autogroup for better desktop scheduling
    };
  };
  services = {
    upower = {
      enable = true;
      percentageLow = 20;
      percentageCritical = 5;
      percentageAction = 3;
      criticalPowerAction = "PowerOff";
    };

    tlp = {
      enable = true;

      # Disable TLP's default settings
      # This is useful if you want to manage power settings manually
      # or if you're using another power management tool
      # like power-profiles-daemon or laptop-mode-tools
      # tlp.defaultSettings = false;

      # Enable TLP's battery charge thresholds
      # This is useful for battery health management
      # tlp.batteryChargeThresholds = true;

      settings = {
        # CPU governor settings
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        # CPU performance levels
        CPU_MIN_PERF_ON_AC = 70;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 70;

        # Battery charge thresholds (for battery health)
        START_CHARGE_THRESH_BAT0 = 20; # Start charging when below 40%
        STOP_CHARGE_THRESH_BAT0 = 80; # Stop charging when above 80%

        # CPU energy performance policy
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_ENERGY_PERf_POLICY_ON_BAT = "balance_performance";

        # CPU boost settings
        CPU_BOOST_ON_AC = 1; # Enable CPU boost on AC
        CPU_BOOST_ON_BAT = 1; # Enable CPU boost on battery
        CPU_HWP_DYN_BOOST_ON_AC = 1; # Enable HWP dynamic boost on AC
        CPU_HWP_DYN_BOOST_ON_BAT = 1; # Enable HWP dynamic boost on battery
        CPU_SCALING_MIN_FREQ_ON_AC = 1000000; # 1000 MHz
        CPU_SCALING_MAX_FREQ_ON_AC = 5200000; # 5200 MHz
        CPU_SCALING_MIN_FREQ_ON_BAT = 400000; # 400 MHz
        CPU_SCALING_MAX_FREQ_ON_BAT = 4000000; # 4000 MHz

        # Platform profile settings
        PLATFORM_PROFILE_ON_AC = "performance";
        PLATFORM_PROFILE_ON_BAT = "powersave";

        # Intel GPU frequency settings
        INTEL_GPU_MIN_FREQ_ON_AC = 1500; # 1500 MHz
        INTEL_GPU_MIN_FREQ_ON_BAT = 1000; # 1000 MHz
        INTEL_GPU_MAX_FREQ_ON_AC = 1500; # 1500 MHz
        INTEL_GPU_MAX_FREQ_ON_BAT = 100; # 100 MHz
        INTEL_GPU_BOOST_FREQ_ON_AC = 1500; # 1500 MHz
        INTEL_GPU_BOOST_FREQ_ON_BAT = 1500; # 1500 MHz

        # Intel GPU power saving settings
        # Enable power saving features for Intel GPU
        # This is useful for reducing power consumption
        # and improving battery life
        # INTEL_GPU_ENABLE_PS_ON_AC = 1; # Enable power saving on AC
        INTEL_GPU_ENABLE_PS_ON_BAT = 1; # Enable power saving on battery
        INTEL_GPU_ENABLE_FBC_ON_AC = 1; # Enable frame buffer compression on AC
        INTEL_GPU_ENABLE_FBC_ON_BAT = 1; # Enable frame buffer compression on battery
        INTEL_GPU_ENABLE_PSR_ON_AC = 1; # Enable panel self-refresh on AC
        INTEL_GPU_ENABLE_PSR_ON_BAT = 1; # Enable panel self-refresh on battery
        INTEL_GPU_ENABLE_GAMING_ON_AC = 1; # Enable gaming mode on AC
        INTEL_GPU_ENABLE_GAMING_ON_BAT = 1; # Enable gaming mode on battery
        INTEL_GPU_ENABLE_VRR_ON_AC = 1; # Enable variable refresh rate on AC
        INTEL_GPU_ENABLE_VRR_ON_BAT = 1; # Enable variable refresh rate on battery

        # PCI Express Active State Power Management
        # PCIE_ASPM_ON_AC = "default";
        # PCIE_ASPM_ON_BAT = "powersupersave";
      };
    };
  };
}
