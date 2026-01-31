{ config, pkgs, lib, hostname, username, ... }:

{
	imports = [
		../../common/common.nix
		../../hardware/workstation-hardware.nix
		./drives.nix

		./packages.nix
		./services.nix
		./games.nix
		./android.nix

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

	hardware.bluetooth = {
		enable = true;
		powerOnBoot = true;
		settings = {
			General = {
				# Shows battery charge of connected devices on supported
				# Bluetooth adapters. Defaults to 'false'.
				Experimental = true;
				# When enabled other devices can connect faster to us, however
				# the tradeoff is increased power consumption. Defaults to
				# 'false'.
				FastConnectable = true;
			};
			Policy = {
				# Enable all controllers when they are found. This includes
				# adapters present on start as well as adapters that are plugged
				# in later on. Defaults to 'true'.
				AutoEnable = true;
			};
		};
	};
	services.blueman.enable = true;

	hardware.openrazer.enable = true;
	hardware.openrazer.users = ["${username}"];

	hardware.i2c.enable = true;
}
