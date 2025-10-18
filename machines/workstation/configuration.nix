{ config, pkgs, ... }:

{
	imports = [
		../../common/common.nix
		../../hardware/workstation-hardware.nix
	];

	# BOOT
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	networking.hostName = "hruon-nixos-ws";
}
