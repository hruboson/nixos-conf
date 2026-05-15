{ self, inputs, ... }: {
	flake.nixosModules.appPackGames = { config, lib, pkgs, username, ... }: {
		environment.systemPackages = with pkgs; let
		heroicWithExtras = pkgs.heroic.override {
			extraPkgs = pkgs': with pkgs'; [
				gamescope
				gamemode
				wineWowPackages.stable
				winetricks
			];
		};
		in 
		[
			prismlauncher # minecraft foss launcher
			osu-lazer-bin # click the circles
			heroicWithExtras # epic games + steam + gog in one app
			pcsx2 # PS2 emulator
			lutris # Windows games emulator
			bottles # can run windows games if you have the .exe file

			libretro.beetle-psx-hw # possible ps5 controller fix
		];

		programs.gamemode.enable = true;
		programs.gamescope.enable = true;
		programs.steam = {
			enable = true;
			remotePlay.openFirewall = true;
			dedicatedServer.openFirewall = true;
			extraCompatPackages = with pkgs; [
				proton-ge-bin
			];
		};
		hardware.steam-hardware.enable = true;
		hardware.xone.enable = true;

		home-manager.users.${username} = {
			# File types -> app associations
			# mimetype.io/all-types
			xdg.mimeApps = {
				enable = true;
				defaultApplications = {
					
				};
			};
		};
	};
}
