{ config, pkgs, lib, hostname, ... }:

{
	imports = [
		../../common/common.nix
		../../hardware/workstation-hardware.nix
		./kde.nix
	];

	# BOOT
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
	networking.hostName = hostname;
}
