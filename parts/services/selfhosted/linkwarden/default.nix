{ self, inputs, ... }: {
	flake.nixosModules.selfhostedLinkwarden = { config, lib, pkgs, username, ... }: {
		environment.etc."linkwarden/nextauth-secret" = {
			text = inputs.secrets.linkwardenPass;
			mode = "0600";
			user = "linkwarden";
			group = "linkwarden";
		};

		services.linkwarden = {
			enable = true;
			port = 3000;
			host = "0.0.0.0";
			openFirewall = true;

			enableRegistration = true;

			environment = {
				NEXTAUTH_URL = "http://${config.networking.hostName}.local:3000";
			};

			secretFiles = {
				NEXTAUTH_SECRET = "/etc/linkwarden/nextauth-secret";
			};
			
			database = {
				port = 5432;
				host = "127.0.0.1";
				name = "linkwarden";
				user = "linkwarden";
			};
		};
	};
}
