{ self, inputs, ... }: {
    # this is basically the flake-parts boilerplate
    flake.nixosModules.qemuHardware = { config, lib, pkgs, modulesPath, ... }: {
        imports =
            [ (modulesPath + "/profiles/qemu-guest.nix") ];
        boot.initrd.availableKernelModules = [ "xhci_pci" "ohci_pci" "ehci_pci" "virtio_pci" "ahci" "usbhid" "sr_mod" "virtio_blk" ];
        boot.initrd.kernelModules = [ ];
        boot.kernelModules = [ "kvm-amd" ];
        boot.extraModulePackages = [ ];
        fileSystems."/" =
        { 
            device = "/dev/disk/by-uuid/d9c6640c-4394-41cd-866b-839fe05d2efd";
            fsType = "ext4";
        };
        fileSystems."/boot" =
        { 
            device = "/dev/disk/by-uuid/D7A4-614B";
            fsType = "vfat";
            options = [ "fmask=0077" "dmask=0077" ];
        };
        swapDevices = [ ];
        nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    };
}
