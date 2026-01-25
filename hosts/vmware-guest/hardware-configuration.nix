{ config, lib, ... }:

{
  # No QEMU profile - this is VMware!
  imports = [ ];

  boot = {
    # VMware-specific kernel modules
    initrd = {
      availableKernelModules = [ "ata_piix" "mptspi" "uhci_hcd" "ehci_pci" "sd_mod" "sr_mod" "ahci" "nvme" ];
      kernelModules = [ "vmw_pvscsi" ];
    };
    kernelModules = [ "vmw_vsock_vmci_transport" "vmw_balloon" "vmwgfx" ];
    extraModulePackages = [ ];
  };

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
