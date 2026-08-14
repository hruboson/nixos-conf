# self refers to the output of our flake so we can use any modules we defined even in different directories
{ self, inputs, ... }: {
	flake.nixosModules.humilisSystem = { pkgs, lib, hostname, username, ... }: {
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

		system.stateVersion = "26.05";
	};
}
