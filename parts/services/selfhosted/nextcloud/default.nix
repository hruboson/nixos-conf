{ self, inputs, ... }: {
	flake.nixosModules.selfhostedNextcloud = { config, lib, pkgs, username, ... }: 
	let
		fqdn = "${config.networking.hostName}.local";
		dataDir = "/mnt/JARK/nextcloud";
		externalStorageDir = "/mnt/HUSK/nextcloud-external";
	in
	{
		environment.etc."nextcloud-admin-pass".text = inputs.secrets.nextCloudPass;

		services.nextcloud = {
			enable = true;
			hostName = fqdn;
			https = false;
			
			package = pkgs.nextcloud33;
			extraApps = {
				inherit (config.services.nextcloud.package.packages.apps)
					news contacts calendar music tasks
				;
			};
			extraAppsEnable = true;
			
			config = {
				dbtype = "pgsql";
				dbhost = "/run/postgresql";
				dbname = "nextcloud";
				dbuser = "nextcloud";
				
				adminuser = "admin";
				adminpassFile = "/etc/nextcloud-admin-pass";
			};

			settings = {
				overwriteprotocol = "http";
				default_phone_region = "CZ";
			};
			
			datadir = dataDir;
		};

		services.postgresql = {
			enable = true;
			ensureDatabases = [ "nextcloud" ];
			ensureUsers = [
				{
					name = "nextcloud";
					ensureDBOwnership = true;
				}
			];
		};
	};
}
