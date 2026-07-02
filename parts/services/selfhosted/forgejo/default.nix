{ self, inputs, ... }: {
	flake.nixosModules.selfhostedForgejo = { config, lib, pkgs, username, ... }: {
		services.openssh.enable = true;
		services.openssh.ports = [ 2222 ];
		services.forgejo = {
			enable = true;
			lfs.enable = true;

			database.type = "postgres";
			stateDir = "/mnt/HUSK/forgejo";

			settings = {
				server = {
					DOMAIN = "${config.networking.hostName}.local";
					ROOT_URL = "http://${config.networking.hostName}.local:2020/";
					HTTP_ADDR = "0.0.0.0";
					HTTP_PORT = 2020;

					SSH_DOMAIN = "${config.networking.hostName}.local";
					SSH_PORT = lib.head config.services.openssh.ports;
				};
				service = {
					DISABLE_REGISTRATION = true; # false only when registering admin for the first time
				};
			};
		};
	};
}
