{ config, pkgs, ... }:

let
	secrets = import ../../secrets/matrix.nix;
in {
	imports = [
		../../common/common.nix
		../../hardware/server-hardware.nix
	];

	# BOOT
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
	networking.hostName = "hruon-nixos-server";
	networking.firewall.allowedTCPPorts = [ 8008 ];
	networking.hosts."nixosmatrix.local" = [ "192.168.2.188" ];

	services.matrix-synapse = {
		enable = true;

		settings = {
			listeners = [
			{
				port = 8008;
				bind_addresses = [ "0.0.0.0" ];
				type = "http";
				tls = false;
				resources = [
				{ names = [ "client" "federation" ]; compress = false; }
				];
			}
			];

			database = {
				name = "sqlite3";
				args = { database = "/var/lib/matrix-synapse/homeserver.db"; }; # for LAN this should be enough
			};

			public_baseurl = "http://nixosmatrix.local:8008";
			server_name = "nixosmatrix.local";
			federation_domain_whitelist = [];
			
			enable_registration = true;
			enable_registration_without_verification = true; # for now because the registration_shared_secret doesn't work for some reason
			registration_shared_secret = secrets.registration_shared_secret;
		};

		dataDir = "/var/lib/matrix-synapse";
	};
}
