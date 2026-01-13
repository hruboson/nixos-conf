{ config, pkgs, lib, inputs, ... }:

with lib; let
	hyprPluginPkgs = inputs.hyprland-plugins.packages.${pkgs.system};
	hypr-plugin-dir = pkgs.symlinkJoin {
		name = "hyprland-plugins";
		paths = with hyprPluginPkgs; [
			hyprbars
			hyprexpo
		];
	};
in
{
	environment.sessionVariables = { HYPR_PLUGIN_DIR = hypr-plugin-dir; };

	programs.hyprland = {
		enable = true;
		withUWSM = true;
		xwayland.enable = true;
		
		package = inputs.hyprland.packages."${pkgs.system}".hyprland;
	};

	# hypr utils
	environment.systemPackages = lib.mkAfter(with pkgs; [
		killall

		wev
		wayland
		wlr-randr
		wdisplays
		tuigreet

		hyprpaper
		hypridle
		hyprlock
		waybar
		eww

		grim					# Screenshot utility
		slurp					# Select region for grim
		nwg-wrapper				# Custom widget displayer
		vicinae					# Launcher
		pwvucontrol				# volume and sound control
	]);

	services.xserver.enable = false;
	security.polkit.enable = true;
	services.dbus.enable = true;
	hardware.graphics.enable = true;
	
	# QEMU-specific config
	services.xserver.videoDrivers = [ "virtio" ];
	environment.variables.WLE_NO_HARDWARE_CURSORS = "1";

	services.pipewire = {
		enable = true;
		wireplumber.enable = true;
		alsa.enable = true;
		pulse.enable = true;
	};

	# graphical login screen (greetd+tuigreet)
	services.greetd = {
		enable = true;
		settings = {
			default_session = {
				# border=yellow;text=cyan;prompt=cyan;time=yellow;input=yellow;container=black;button=cyan;title=yellow 
				command = ''
				${pkgs.tuigreet}/bin/tuigreet --time 
				--theme "border=yellow;text=cyan"
				--remember --remember-session --cmd start-hyprland";
				user = "greeter'';
			};
		};
	};

	# https://github.com/sjcobb2022/nixos-conf/blob/main/hosts/common/optional/greetd.nix
	systemd.services.greetd.serviceConfig = {
		Type = "idle";
		StandardInput = "tty";
		StandardOutput = "tty";
		StandardError = "journal";
		TTYReset = true;
		TTYYVHangup = true;
		TTYVTDisallocate = true;
	};

}
