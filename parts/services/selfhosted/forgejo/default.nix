{ self, inputs, ... }: {
	flake.nixosModules.selfhostedForgejo = { config, lib, pkgs, username, ... }: {
		services.openssh.enable = true;
		services.openssh.ports = [ 2222 22 ];
	    networking.firewall.allowedTCPPorts = [ 2222 22 ];

		services.forgejo = {
			enable = true;
			lfs.enable = true;

			database.type = "postgres";
			stateDir = "/mnt/HUSK/forgejo";

			settings = {
				server = {
					DOMAIN = config.selfhosted.domain;
					ROOT_URL = "https://forgejo.${config.selfhosted.domain}";
					HTTP_ADDR = "0.0.0.0";
					HTTP_PORT = 2020;

					DISABLE_SSH = false;
					SSH_DOMAIN = "forgejo.${config.selfhosted.domain}";
					SSH_PORT = lib.head config.services.openssh.ports;
				};
				service = {
					DISABLE_REGISTRATION = true; # false only when registering admin for the first time
				};
			};
		};

      	selfhosted.services.forgejo.port = 2020;
	};
}
