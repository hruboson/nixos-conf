{ config, pkgs, lib, hostname, ... }:

{
	imports = [
		../../common/common.nix
		../../hardware/workstation-hardware.nix
		./packages.nix
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

	services.avahi = { # enables .local address resolution
		enable = true;
		nssmdns = true;
		openFirewall = true;
		ipv4 = true;
		ipv6 = true;
	};

	services.power-profiles-daemon.enable = true;
}
