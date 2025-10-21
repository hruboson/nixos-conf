{ config, pkgs, lib, ... }:

{
	imports = [
		../../common/common.nix
		../../hardware/workstation-hardware.nix
	];

	# BOOT
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	networking.hostName = "hruon-nixos-ws";

	# DESKTOP ENVIRONMENT
	services.xserver.enable = true;
	services.displayManager.sddm.enable = true;
	services.desktopManager.plasma6.enable = true;
	security.rtkit.enable = true;

	services.xserver.libinput.enable = true; # enable touchpad

	environment.systemPackages = lib.mkAfter (with pkgs; [
			wl-clipboard
			wayland-utils
			kitty
	]);
}
