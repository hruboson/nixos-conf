{ self, inputs, ... }: {
	flake.nixosModules.selfhostedJellyfin = { config, lib, pkgs, username, ... }: {
		environment.systemPackages = with pkgs; [
			jellyfin
			jellyfin-web
			jellyfin-ffmpeg
		];

		services.jellyfin = {
			enable = true;
			openFirewall = true;
			user = "${username}";
			group = "media";
		};

      	selfhosted.services.jellyfin.port = 8096;
	};
}
