{ self, inputs, ... }: {
	flake.nixosModules.mangoSystem = { config, pkgs, lib, username, ... }: {
		imports = [
			inputs.silentSDDM.nixosModules.default
		];

		#environment.sessionVariables.NIXOS_OZONE_WL = "1";
		programs.dconf.enable = true;
		security.polkit.enable = true;
		services.dbus.enable = true;
		hardware.graphics.enable = true;
		#security.pam.services.hyprlock = {};

		xdg.portal.enable = true;
		xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

		services.xserver.enable = true;

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
				"LoginScreen" = { background = "water.jpg"; blur = 5; };
				"LockScreen"  = { background = "water.jpg"; blur = 5; };
				"General"     = { background-fill-mode = "fill"; };
			};
			profileIcons = {
				${username} = pkgs.fetchurl {
					name = "hruon_logo.jpg";
					url = "https://raw.githubusercontent.com/hruboson/wallpapers/main/logos/inversion.png";
					hash = "sha256-7oa2vQaWmsQ+evWES1XNVBfI///McOv+J/9urFN1kEM=";
				};
			};
		};

		services.displayManager.sddm = {
			enable = true;
			settings = {
				Autologin = {
					Session = "mango";  # matches the .desktop session name mango installs
					User = username;
					Relogin = false;
				};
			};
		};
	};
}
