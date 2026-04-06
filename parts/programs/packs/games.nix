{ self, inputs, ... }: {
	flake.nixosModules.appPackGames = { config, lib, pkgs, username, ... }: {
		environment.systemPackages = with pkgs; [
			prismlauncher # minecraft foss launcher
			osu-lazer-bin # click the circles
			heroic # epic games + steam + gog in one app
			pcsx2 # PS2 emulator
		];

		programs.gamemode.enable = true;
		programs.steam = {
			enable = true;
			remotePlay.openFirewall = true;
			dedicatedServer.openFirewall = true;
			extraCompatPackages = with pkgs; [
				proton-ge-bin
			];
		};

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
