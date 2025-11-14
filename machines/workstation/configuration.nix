{ config, pkgs, lib, hostname, ... }:

{
	imports = [
		../../common/common.nix
		../../hardware/workstation-hardware.nix
		#./kde.nix
	];

	# BOOT
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
	networking.hostName = hostname;

	programs.sway.enable = true;
	services.xserver.enable = false; # disable X11
	security.polkit.enable = true;

	# for QEMU
	services.xserver.videoDrivers = [ "virtio" ];

	# enable hardware acceleration
	hardware.opengl = {
		enable = true;
	};

	# sway utils
	environment.systemPackages = lib.mkAfter(with pkgs; [
		wayland
		wlr-randr
		swaybg
		swaylock
		swayidle
		kitty
	]);
}
