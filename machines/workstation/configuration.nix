{ config, pkgs, lib, hostname, ... }:

{
	imports = [
		../../common/common.nix
		../../hardware/workstation-hardware.nix
		./packages.nix
		./services.nix

		./hypr.nix
		#./mango.nix
		#./sway.nix
		#./kde.nix
	];

	# BOOT
	#boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;
	boot.loader.grub = {
		enable = true;
		devices = [ "nodev" ];
		efiSupport = true;
		useOSProber = true;
		default = "saved";
	};

	networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
	networking.hostName = hostname;
	networking.firewall = {
		# bambulab networking
		extraCommands = ''
			iptables -I INPUT -m pkttype --pkt-type multicast -j ACCEPT
			iptables -A INPUT -m pkttype --pkt-type multicast -j ACCEPT
			iptables -I INPUT -p udp -m udp --match multiport --dports 1990,2021 -j ACCEPT
			'';
	};
}
