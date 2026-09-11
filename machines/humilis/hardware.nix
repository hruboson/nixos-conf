{ self, inputs, ... }: {
  flake.nixosModules.humilisHardware =
    { pkgs, lib, ... }:
    {
      hardware = {
        enableRedistributableFirmware = true;
      };

      fileSystems = {
        "/" = {
          device = "/dev/disk/by-label/NIXOS_SD";
          fsType = "ext4";
        };
      };

	  swapDevices = [{ device = "/swapfile"; size = 2048; }];
    };
}
