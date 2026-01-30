{ config, pkgs, lib, inputs, secrets, ... }:

let
	fqdn = "${config.networking.hostName}.local";
	baseUrl = "http://${fqdn}:8008"; # local-only
in
{
	environment.etc."matrix/registration-secret" = {
		text = ''registration_shared_secret: ${secrets.matrixRegistrationSecret}'';
		mode = "0400";
		user = "matrix-synapse";
		group = "matrix-synapse";
	};
	services.matrix-synapse = {
		enable = true;
		extraConfigFiles = [
			"/etc/matrix/registration-secret"
		];

		settings = {
			server_name = fqdn;
			public_baseurl = baseUrl;
			federation_enabled = false; # currently running on LAN only

			database = {
				name = "psycopg2";
				args = {
					database = "matrix-synapse";
					user = "matrix-synapse";
					host = "127.0.0.1";
					port = 5432;
				};
			};

			listeners = [
			{
				port = 8448;
				bind_addresses = [ "0.0.0.0" ];
				type = "http";
				tls = false;
				x_forwarded = false;
				resources = [
				{
					names = [ "client" ];
					compress = true;
				}
				];
			}
			];

			enable_registration = false;
		};
	};
}
