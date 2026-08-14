{ self, inputs, ... }: {
  flake.nixosModules.humilisHardware =
    { pkgs, lib, ... }:
    {
      hardware = {
        enableRedistributableFirmware = true;
        /*firmware = [ pkgs.wireless-regdb ];
        raspberry-pi.firmware = {
          enable = true;
          uboot.enable = true;
        };
		configtxt.settings.all.hdmi_force_hotplug = 1;*/
      };

      boot.loader.grub.enable = false;
      boot.loader.generic-extlinux-compatible.enable = true;

      # !!! Needed for the virtual console to work on the RPi 3, as the default of 16M doesn't seem to be enough.
      # If X.org behaves weirdly (I only saw the cursor) then try increasing this to 256M.
      # On a Raspberry Pi 4 with 4 GB, you should either disable this parameter or increase to at least 64M if you want the USB ports to work.
      boot.kernelParams = [ "cma=256M" ];
      #boot.kernelPackages = lib.mkForce pkgs.linuxKernel.packages.linux_rpi3;

      boot.supportedFilesystems = lib.mkForce [
        "vfat"
        "xfs"
        "cifs"
        "ntfs"
      ];

      fileSystems = {
        "/" = {
          device = "/dev/disk/by-label/NIXOS_SD";
          fsType = "ext4";
        };
      };

	  swapDevices = [{ device = "/swapfile"; size = 2048; }];
    };
}
