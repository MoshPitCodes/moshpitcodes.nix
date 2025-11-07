{ config, lib, pkgs, modulesPath, ... }:

{
  # No QEMU profile - this is VMware!
  imports = [ ];

  # VMware-specific kernel modules
  boot.initrd.availableKernelModules = [ "ata_piix" "mptspi" "uhci_hcd" "ehci_pci" "sd_mod" "sr_mod" "ahci" "nvme" ];
  boot.initrd.kernelModules = [ "vmw_pvscsi" ];
  boot.kernelModules = [ "vmw_vsock_vmci_transport" "vmw_balloon" "vmwgfx" ];
  boot.extraModulePackages = [ ];

  # Adjust these values based on your actual VM configuration
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  # VMware typically uses this swap configuration
  swapDevices = [ { device = "/dev/disk/by-label/swap"; } ];

  # Enable VMware specific hardware
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
} 