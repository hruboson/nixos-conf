{ config, pkgs, lib, ... }:

{
	# graphical login screen (greetd+tuigreet)
	services.greetd = {
		enable = true;
		settings = {
			default_session = {
				# border=yellow;text=cyan;prompt=cyan;time=yellow;input=yellow;container=black;button=cyan;title=yellow 
				command = ''
				${pkgs.greetd.tuigreet}/bin/tuigreet --time 
				--theme "border=yellow;text=cyan"
				--remember --remember-session --cmd sway";
				user = "greeter'';
			};
		};
	};

	# https://github.com/sjcobb2022/nixos-conf/blob/main/hosts/common/optional/greetd.nix
	systemd.services.greetd.serviceConfig = {
		Type = "idle";
		StandardInput = "tty";
		StandardOutput = "tty";
		StardardError = "journal";
		TTYReset = true;
		TTYYVHangup = true;
		TTYVTDisallocate = true;
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
