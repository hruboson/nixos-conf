# self refers to the output of our flake so we can use any modules we defined even in different directories
{ self, inputs, ... }: {
	flake.nixosModules.fractusSystem = { pkgs, lib, hostname, username, ... }: {
		boot.loader.efi.canTouchEfiVariables = true;
		boot.loader.grub = {
			enable = true;
			devices = [ "nodev" ];
			efiSupport = true;
			useOSProber = true;
			default = "saved";
		};
		boot.supportedFilesystems = [ "ntfs" ];

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
				General = { Experimental = true; FastConnectable = true; };
				Policy = { AutoEnable = true; };
			};
		};
		services.blueman.enable = true;
		hardware.i2c.enable = true;
		hardware.graphics = { enable = true; enable32Bit = true; };

		system.stateVersion = "25.11";
	};
}
