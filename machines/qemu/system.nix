# self refers to the output of our flake so we can use any modules we defined even in different directories
{ self, inputs, ... }: {
	flake.nixosModules.qemuSystem = { pkgs, lib, hostname, username, ... }: {
		boot.loader.efi.canTouchEfiVariables = true;
		boot.loader.grub = {
			enable = true;
			devices = [ "nodev" ];
			efiSupport = true;
			useOSProber = true;
			default = "saved";
		};
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
		hardware.openrazer.enable = true;
		hardware.openrazer.users = [ username ];
		hardware.i2c.enable = true;
		hardware.graphics = { enable = true; enable32Bit = true; };

		services.xserver.videoDrivers = [ "virtio" ];
		environment.sessionVariables.WLR_RENDERER_ALLOW_SOFTWARE = "1";
		environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";
		system.stateVersion = "25.11";
	};
}
