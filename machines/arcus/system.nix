# self refers to the output of our flake so we can use any modules we defined even in different directories
{ self, inputs, ... }: {
	flake.nixosModules.arcusSystem = { pkgs, lib, hostname, username, ... }: {
		boot.loader.efi.canTouchEfiVariables = true;
		boot.loader.grub = {
			enable = true;
			devices = [ "nodev" ];
			efiSupport = true;
			useOSProber = true;
			default = "saved";
		};
		boot.supportedFilesystems = [ "ntfs" ];

		fileSystems."/mnt/DELTA" = {
			device = "/dev/disk/by-uuid/B8ACE2A5ACE25CFE";
			fsType = "ntfs-3g"; # ntfs-3g is recommended over ntfs3 for more stability when sharing the drive between Windows and Linux systems
				options = [ "rw" "noatime" "nofail" "uid=1000" "gid=100" "x-systemd.automount" ]; # all options at https://www.mankier.com/5/systemd.mount or `man systemd.mount`
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

		services.xserver.videoDrivers = [ "amdgpu" ];
		system.stateVersion = "25.11";
	};
}
