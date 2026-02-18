# Desktop host configuration (i7-13700K, RTX 4070Ti Super)
{
  pkgs,
  lib,
  username,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./nas-mount.nix
    ../../modules/core
    ../../modules/core/nvidia.nix
    ../../modules/core/samba.nix
    ../../modules/core/steam.nix
    ../../modules/core/flatpak.nix
    ../../modules/core/virtualization.nix
    ../../modules/core/desktop-overrides.nix
  ];

  # Hostname
  networking.hostName = "desktop";

  # Desktop boot configuration (high-performance, silent boot)
  boot = {
    consoleLogLevel = 3;

    initrd = {
      verbose = false;
      kernelModules = [
        "nvidia"
        "nvidia_modeset"
        "nvidia_uvm"
        "nvidia_drm"
        # USB modules for faster keyboard/mouse detection
        "usbhid"
        "hid_generic"
        "hid_steelseries" # SteelSeries devices support
      ];
      # Reduce systemd timeout for faster boot
      systemd.enable = true;
    };

    loader.timeout = 0; # Silent boot

    kernelModules = [
      "acpi_call"
      "btusb"
      "coretemp"
      "intel_pstate"
      "intel_rapl"
      "intel_rapl_perf"
      "kvm-intel"
      "msr"
      "snd_hda_intel"
    ];

    kernelParams = [
      "intel_pstate=active"
      "mitigations=auto"
      "threadirqs"
      "nowatchdog"
      "nvidia-drm.modeset=1"
      "video=DP-1:2560x1440@120" # Center monitor (Dell) - primary display
      "video=HDMI-A-1:1920x1080@60" # Left monitor (Samsung portrait)
      "video=DP-2:2560x1440@120" # Right monitor (AOC)
      # USB optimization for faster device detection
      "usbcore.autosuspend=-1" # Disable USB autosuspend
      "usbcore.use_both_schemes=y" # Try both old and new USB schemes
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
    ];

    kernel.sysctl = {
      "vm.swappiness" = 10;
      "vm.dirty_ratio" = 60;
      "vm.dirty_background_ratio" = 30;
      "kernel.sched_autogroup_enabled" = 0;
    };
  };

  # Reduce systemd timeout for faster boot
  systemd.services = {
    systemd-udev-settle.serviceConfig.TimeoutSec = "10s"; # Reduce from default 180s
  };

  # Optimize systemd-networkd-wait-online (if enabled)
  systemd.network.wait-online.enable = false;

  # SSH for remote access
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = true;
      AllowUsers = [ username ];
      PermitRootLogin = "no";
    };
  };

  # Open firewall for SSH
  networking.firewall.allowedTCPPorts = [ 22 ];

  # GNOME Keyring - auto-unlock with PAM
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;

  # Hardware monitoring and fan control
  environment.systemPackages = with pkgs; [
    lm_sensors # Includes fancontrol, sensors, sensors-detect
    coolercontrol.coolercontrol-gui # GUI for fan curves and RGB control
    coolercontrol.coolercontrold # Daemon backend
  ];

  # CoolerControl daemon service
  systemd.services.coolercontrold = {
    description = "CoolerControl Daemon";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.coolercontrol.coolercontrold}/bin/coolercontrold";
      Restart = "on-failure";
    };
  };

  # Storage drive auto-mount (old NixOS install reformatted as storage)
  fileSystems."/mnt/storage" = {
    device = "/dev/disk/by-label/storage";
    fsType = "ext4";
    options = [
      "defaults"
      "nofail" # Don't fail boot if drive is missing
    ];
  };

  # Automatically set ownership on storage mount
  system.activationScripts.setupStorage = ''
    if [ -d /mnt/storage ]; then
      chown ${username}:users /mnt/storage
      chmod 755 /mnt/storage
    fi
  '';
}
