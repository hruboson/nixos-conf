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

	# graphical login screen (greetd+tuigreet)
	services.greetd = {
		enable = true;
		settings = {
			default_session = {
				command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd sway";
				user = "greeter";
			};
		};
	};

	programs.sway.enable = true;
	services.xserver.enable = false; # disable X11
	security.polkit.enable = true;

	# for QEMU
	services.xserver.videoDrivers = [ "virtio" ];
	environment.variables.WLR_NO_HARDWARE_CURSORS = "1";

	# enable hardware acceleration
	hardware.graphics = {
		enable = true;
	};

	# sway utils
	environment.systemPackages = lib.mkAfter(with pkgs; [
		greetd.tuigreet
		wayland
		wlr-randr
		swaybg
		swaylock
		swayidle
		kitty
	]);
}
