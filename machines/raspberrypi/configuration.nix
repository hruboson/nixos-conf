{ config, pkgs, ... }:

{
	imports = [
		../../common/common.nix
		../../hardware/raspberrypi-hardware.nix
	];

	# BOOT
	boot.loader.grub.enable = false;
	boot.loader.raspberryPi.enable = true;
	boot.loader.raspberryPi.version = 3;

	networking.hostName = "hruon-nixos-rpi3";
}
