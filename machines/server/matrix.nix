{ config, pkgs, lib, inputs, secrets, ... }:

let
	fqdn = "${config.networking.hostName}.${config.networking.domain}";
	baseUrl = "http://${fqdn}:8008"; # local-only
in
{
	environment.etc."matrix/registration-secret" = {
		text = ''
			registration_shared_secret: ${secrets.matrixRegistrationSecret}
		'';
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
			server_name = config.networking.domain;
			public_baseurl = baseUrl;

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
				port = 8008;
				bind_addresses = [ "0.0.0.0" "::" ];
				type = "http";
				tls = false;
				x_forwarded = false;
				resources = [
				{
					names = [ "client" "federation" ];
					compress = true;
				}
				];
			}
			];

			enable_registration = false;
		};
	};
}
