# Laptop host configuration (ASUS Zenbook 14X OLED)
{
  pkgs,
  lib,
  config,
  username,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/core
    ../../modules/core/nas-mount.nix
    ../../modules/core/samba.nix
    ../../modules/core/flatpak.nix
    ../../modules/core/virtualization.nix
  ];

  # Hostname
  networking.hostName = "laptop";

  # Boot configuration optimized for laptop
  boot = {
    # Silent boot for clean startup
    consoleLogLevel = 3;
    initrd = {
      verbose = false;
      # Intel i915 GPU early KMS for proper framebuffer resolution
      kernelModules = [ "i915" ];
    };

    # Hide bootloader menu (press any key to show)
    loader.timeout = 0;

    # Laptop-specific kernel modules
    kernelModules = [
      "acpi_call" # ACPI calls for power management
      "btusb" # Bluetooth USB
      "coretemp" # CPU temperature monitoring
      "hid_multitouch" # Touchscreen/touchpad multitouch
      "intel_pstate" # Intel P-state CPU frequency scaling
      "intel_rapl" # Intel RAPL (power limiting)
      "intel_rapl_perf" # Intel RAPL performance counters
      "iwlwifi" # Intel WiFi
      "kvm-intel" # KVM virtualization
      "msr" # CPU model-specific registers
      "snd_hda_intel" # Intel HDA audio
      # USB Ethernet adapter support (for USB-C docks)
      "ax88179_178a" # ASIX AX88179/178A USB 3.0 Gigabit Ethernet
      "cdc_ether" # USB CDC Ethernet
      "usbnet" # USB network device support
    ];

    extraModulePackages = with config.boot.kernelPackages; [ cpupower ];

    # Kernel parameters for laptop performance and power management
    kernelParams = [
      "i915.force_probe=a7a0" # Force probe Intel Iris Xe Graphics (adjust PCI ID if needed)
      "intel_pstate=active" # Active Intel P-state for better power management
      "threadirqs" # Threading for IRQs (improves responsiveness)
      "nowatchdog" # Disable watchdog (slight performance improvement)
      "nvme.noacpi=1" # Improve NVMe performance (bypass ACPI)
      "quiet" # Suppress kernel messages during boot
      "splash" # Enable Plymouth splash screen
      "boot.shell_on_fail" # Drop to shell on boot failure
      "udev.log_priority=3" # Reduce udev log verbosity
      "rd.systemd.show_status=auto" # Show systemd status on boot
    ];

    # Kernel sysctl tuning for laptop
    kernel.sysctl = {
      "vm.swappiness" = 10; # Reduce swap usage (prefer RAM)
      "vm.vfs_cache_pressure" = 50; # Better file caching
      "vm.dirty_background_ratio" = 30; # Start writing dirty pages at 30%
      "kernel.sched_autogroup_enabled" = 0; # Disable autogroup for better desktop scheduling
    };
  };

  # Reduce systemd timeout for faster boot (matches desktop)
  systemd.services = {
    systemd-udev-settle.serviceConfig.TimeoutSec = "10s"; # Reduce from default 180s
  };

  # Disable network-wait-online for faster boot (matches desktop)
  systemd.network.wait-online.enable = false;

  # Laptop-specific packages
  environment.systemPackages = with pkgs; [
    acpi # ACPI utilities
    brightnessctl # Screen brightness control
    cpupower-gui # CPU frequency and power management GUI
    powertop # Power consumption analyzer
  ];

  # TLP power management (optimized for battery life and performance)
  services.tlp = {
    enable = true;

    settings = {
      # CPU governor settings
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      # CPU performance levels (Intel P-state)
      CPU_MIN_PERF_ON_AC = 70;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 70;

      # Battery charge thresholds (preserve battery health)
      START_CHARGE_THRESH_BAT0 = 20; # Start charging below 20%
      STOP_CHARGE_THRESH_BAT0 = 80; # Stop charging at 80%

      # CPU energy performance policy
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_performance";

      # CPU boost settings
      CPU_BOOST_ON_AC = 1; # Enable turbo boost on AC
      CPU_BOOST_ON_BAT = 1; # Enable turbo boost on battery
      CPU_HWP_DYN_BOOST_ON_AC = 1; # Hardware P-state dynamic boost on AC
      CPU_HWP_DYN_BOOST_ON_BAT = 1; # Hardware P-state dynamic boost on battery

      # CPU frequency limits
      CPU_SCALING_MIN_FREQ_ON_AC = 1000000; # 1.0 GHz minimum on AC
      CPU_SCALING_MAX_FREQ_ON_AC = 5200000; # 5.2 GHz maximum on AC (turbo)
      CPU_SCALING_MIN_FREQ_ON_BAT = 400000; # 400 MHz minimum on battery
      CPU_SCALING_MAX_FREQ_ON_BAT = 4000000; # 4.0 GHz maximum on battery

      # Platform profile (ACPI)
      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "powersave";

      # Intel GPU frequency settings
      INTEL_GPU_MIN_FREQ_ON_AC = 1500; # 1500 MHz minimum on AC
      INTEL_GPU_MIN_FREQ_ON_BAT = 1000; # 1000 MHz minimum on battery
      INTEL_GPU_MAX_FREQ_ON_AC = 1500; # 1500 MHz maximum on AC
      INTEL_GPU_MAX_FREQ_ON_BAT = 1000; # 1000 MHz maximum on battery (power saving)
      INTEL_GPU_BOOST_FREQ_ON_AC = 1500; # 1500 MHz boost on AC
      INTEL_GPU_BOOST_FREQ_ON_BAT = 1500; # 1500 MHz boost on battery

      # Intel GPU power saving features
      INTEL_GPU_ENABLE_PS_ON_BAT = 1; # Enable power saving on battery
      INTEL_GPU_ENABLE_FBC_ON_AC = 1; # Frame buffer compression on AC
      INTEL_GPU_ENABLE_FBC_ON_BAT = 1; # Frame buffer compression on battery
      INTEL_GPU_ENABLE_PSR_ON_AC = 1; # Panel self-refresh on AC
      INTEL_GPU_ENABLE_PSR_ON_BAT = 1; # Panel self-refresh on battery
    };
  };

  # UPower battery monitoring and power actions
  services.upower = {
    enable = true;
    percentageLow = 20; # Low battery warning at 20%
    percentageCritical = 5; # Critical battery warning at 5%
    percentageAction = 3; # Emergency action at 3%
    criticalPowerAction = "PowerOff"; # Power off at critical battery
  };

  # SSH for remote access
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = false; # Key-only authentication
      AllowUsers = [ username ];
      PermitRootLogin = "no";
    };
  };

  # Firewall configuration
  networking.firewall.allowedTCPPorts = [ 22 ];

  # GNOME Keyring - auto-unlock with PAM (matches desktop)
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
}
