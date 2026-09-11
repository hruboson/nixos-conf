# self refers to the output of our flake so we can use any modules we defined even in different directories
{ self, inputs, ... }: {
  flake.nixosModules.humilisSystem =
    {
      pkgs,
      lib,
      hostname,
      username,
      ...
    }:
    {

      boot.loader.grub.enable = false;
      boot.loader.generic-extlinux-compatible.enable = true;

      # !!! Needed for the virtual console to work on the RPi 3, as the default of 16M doesn't seem to be enough.
      # If X.org behaves weirdly (I only saw the cursor) then try increasing this to 256M.
      # On a Raspberry Pi 4 with 4 GB, you should either disable this parameter or increase to at least 64M if you want the USB ports to work.
      boot.kernelParams = [ "cma=256M" ];
	  boot.kernelPackages = pkgs.linuxPackages;
	  boot.blacklistedKernelModules = [ "raspberrypi_hwmon" ];

      boot.supportedFilesystems = lib.mkForce [
        "vfat"
        "xfs"
        "cifs"
        "ntfs"
      ];

      networking.networkmanager.enable = true;
      networking.hostName = hostname;
      networking.firewall.extraCommands = ''
        iptables -I INPUT -m pkttype --pkt-type multicast -j ACCEPT
        iptables -A INPUT -m pkttype --pkt-type multicast -j ACCEPT
        iptables -I INPUT -p udp -m udp --match multiport --dports 1990,2021 -j ACCEPT
      '';
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
        settings = {
          General = {
            Experimental = true;
            FastConnectable = true;
          };
          Policy = {
            AutoEnable = true;
          };
        };
      };

      system.stateVersion = "26.05";
    };
}
