{ self, inputs, ... }: {
	flake.nixosModules.eliskaHardware = { config, lib, pkgs, modulesPath, ... }: {
		imports =
			[ (modulesPath + "/installer/scan/not-detected.nix")
			];

		boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "vmd" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
		boot.initrd.kernelModules = [ ];
		boot.kernelModules = [ "kvm-intel" ];
		boot.extraModulePackages = [ ];

		fileSystems."/" =
		{ device = "/dev/disk/by-uuid/f2db29fd-b3b5-4b96-8295-0c40a7633e9e";
			fsType = "ext4";
		};

		fileSystems."/boot" =
		{ device = "/dev/disk/by-uuid/2916-0C9F";
			fsType = "vfat";
			options = [ "fmask=0077" "dmask=0077" ];
		};

		swapDevices =
			[ { device = "/dev/disk/by-uuid/f7651766-be87-47ef-b583-de634ebcd095"; }
			];

			nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
			hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
	};
}
