{ self, inputs, ... }: {
	flake.nixosModules.selfhostedMatrix = { config, lib, pkgs, username, ... }: 
	let
		fqdn = "${config.networking.hostName}.local";
	in
	{
		services.matrix-tuwunel = {
			enable = true;

			settings = {
				global = {
					server_name = fqdn;

					# Listen only on LAN
					address = [ "0.0.0.0" ];
					port = [ 6167 ];  # default for tuwunel

					# Disable federation completely
					allow_federation = false;
					allow_encryption = true;
					allow_registration = true;
					registration_token = "${inputs.secrets.matrixRegistrationSecret}";

					trusted_servers = [];
					max_request_size = 100000000; # 100 MB
				};
			};

			# keep default state dir
			stateDirectory = "matrix-tuwunel";
		};
	};
}
