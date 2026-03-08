{ config, pkgs, lib, inputs, ... }:

with lib; let
	hyprPluginPkgs = inputs.hyprland-plugins.packages.${pkgs.system};
	hypr-plugin-dir = pkgs.symlinkJoin {
		name = "hyprland-plugins";
		paths = [
			hyprPluginPkgs.hyprbars
			#hyprPluginPkgs.hyprexpo
			#inputs.Hyprspace.packages.${pkgs.system}.Hyprspace
		];
	};

	hypr-overview = pkgs.fetchFromGitHub {
		owner = "Shanu-Kumawat";
		repo = "quickshell-overview";
		rev = "main";
		sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
	};
in
{
	imports = [
		inputs.silentSDDM.nixosModules.default
	];

	environment.sessionVariables.HYPR_PLUGIN_DIR = hypr-plugin-dir;
	environment.sessionVariables.NIXOS_OZONE_WL = "1"; # This variable fixes electron apps in wayland

	programs.dconf.enable = true;

	programs.hyprland = {
		enable = true;
		withUWSM = true;
		xwayland.enable = true;
		
		package = inputs.hyprland.packages."${pkgs.system}".hyprland;
	};

	xdg.portal.enable = true;
	xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

	services.xserver = {
		enable = true;

		xrandrHeads = [
		{
			output = "DP-2";
			primary = true;
		}
		{
			output = "HDMI-A-1";
		}
		{
			output = "HDMI-A-2";
		}
		];
	};

	security.pam.services.hyprlock = {};
	programs.silentSDDM = {
		enable = true;
		theme = "default";
		
		backgrounds = {
			wallpaper = pkgs.fetchurl {
				name = "water.jpg";
				url = "https://raw.githubusercontent.com/hruboson/wallpapers/main/fruitiger_aero/drop.jpg";
				hash = "sha256-82eyZ5MgykxnxKP1aoHEXjRXTLXTbb9HxIT1eC24dDY=";
			};
		};
		
		settings = {
            "LoginScreen" = {
            	background = "water.jpg";
				blur = 5;
            };
            "LockScreen" = {
            	background = "water.jpg";
				blur = 5;
            };
			"General" = {
				background-fill-mode = "fill";
			};
		};

		profileIcons = {
			hruon = pkgs.fetchurl {
				name = "hruon_logo.jpg";
				url = "https://raw.githubusercontent.com/hruboson/wallpapers/main/logos/inversion.png";
				hash = "sha256-7oa2vQaWmsQ+evWES1XNVBfI///McOv+J/9urFN1kEM=";
			};
		};
	};
	services.displayManager.sddm = {
		enable = true;
		autoLogin.relogin = false;
		
		settings = {
			Autologin = {
				Session = "start-hyprland";
				User = "hruon";
				Relogin = false;
			};
		};
	};

	security.polkit.enable = true;
	services.dbus.enable = true;
	hardware.graphics.enable = true;

	# hypr utils
	environment.systemPackages = lib.mkAfter(with pkgs; [
		killall

		wev
		wayland
		wlr-randr
		wdisplays

		hyprpaper
		hyprshade
		hyprsunset
		waybar
		waybar-mpris
		eww
		quickshell
		qt6.qtwayland

		grim					# Screenshot utility
		slurp					# Select region for grim
		nwg-wrapper				# Custom widget displayer
		vicinae					# Launcher
		pwvucontrol				# volume and sound gui control
		pulseaudio				# volume and sound control
		inputs.snappy-switcher.packages.${pkgs.system}.default
	]);
}
