{ self, inputs, ... }: {
    # this is basically the flake-parts boilerplate
    flake.nixosModules.arcusHardware = { config, lib, pkgs, modulesPath, ... }: {
        imports =
	    [ (modulesPath + "/installer/scan/not-detected.nix")
	    ];

	  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
	  boot.initrd.kernelModules = [ ];
	  boot.kernelModules = [ "kvm-amd" ];
	  boot.extraModulePackages = [ ];

	  fileSystems."/" =
	    { device = "/dev/disk/by-uuid/03348182-c681-4b0f-a55d-c6f8d147ee1c";
	      fsType = "ext4";
	    };

	  fileSystems."/boot" =
	    { device = "/dev/disk/by-uuid/BF2C-9B47";
	      fsType = "vfat";
	      options = [ "fmask=0077" "dmask=0077" ];
	    };

	  swapDevices =
	    [ { device = "/dev/disk/by-uuid/81d7258b-a2f9-408f-a0d6-6c8595da3f5c"; }
	    ];

	  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
	  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
}
