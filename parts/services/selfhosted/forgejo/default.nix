{ self, inputs, ... }: {
	flake.nixosModules.selfhostedForgejo = { config, lib, pkgs, username, ... }: {
		services.forgejo = {
			enable = true;
			lfs.enable = true;

			database.type = "postgres";

			settings = {
				server = {
					DOMAIN = "${config.networking.hostName}.local";
					ROOT_URL = "http://${config.networking.hostName}.local:2020/";
					HTTP_PORT = 2020;
					SSH_DOMAIN = "${config.networking.hostName}.local";
					HTTP_ADDR = "0.0.0.0";
				};
				service = {
					DISABLE_REGISTRATION = false; # false only when registering admin for the first time
				};
			};
		};
	};
}
