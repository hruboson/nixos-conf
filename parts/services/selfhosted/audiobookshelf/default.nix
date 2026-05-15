{ self, inputs, ... }: {
	flake.nixosModules.selfhostedAudiobookshelf = { config, lib, pkgs, username, ... }: {
		services.audiobookshelf = {
			enable = true;
			port = 8010;
			host = "0.0.0.0";
			openFirewall = true;
		};
		users.users.audiobookshelf.extraGroups = [ "media" ];
	};
}
