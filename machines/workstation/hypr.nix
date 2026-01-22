{ config, pkgs, lib, inputs, ... }:

with lib; let
	hyprPluginPkgs = inputs.hyprland-plugins.packages.${pkgs.system};
	hypr-plugin-dir = pkgs.symlinkJoin {
		name = "hyprland-plugins";
		paths = [
			hyprPluginPkgs.hyprbars
			hyprPluginPkgs.hyprexpo
			inputs.Hyprspace.packages.${pkgs.system}.Hyprspace
		];
	};
in
{
	environment.sessionVariables.HYPR_PLUGIN_DIR = hypr-plugin-dir;
	environment.sessionVariables.NIXOS_OZONE_WL = "1"; # This variable fixes electron apps in wayland

	programs.hyprland = {
		enable = true;
		withUWSM = true;
		xwayland.enable = true;
		
		package = inputs.hyprland.packages."${pkgs.system}".hyprland;
	};

	xdg.portal.enable = true;
	xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

	services.xserver.enable = true;
	services.displayManager.sddm = {
		enable = true;
		extraPackages = [ pkgs.sddm-astronaut ];
		theme = "sddm-astronaut-theme";
		autoLogin.relogin = false;
		wayland.enable = true;
		settings = {
			Autologin = {
				Session = "start-hyprland";
				User = "hruon";
				Relogin = false;
			};
			#Theme = {
			#	Current = "sddm-astronaut-theme";
			#};
		};
	};

	security.polkit.enable = true;
	services.dbus.enable = true;
	hardware.graphics.enable = true;

	# hypr utils
	environment.systemPackages = lib.mkAfter(with pkgs; [
		killall
		sddm-astronaut

		wev
		wayland
		wlr-randr
		wdisplays

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
}
