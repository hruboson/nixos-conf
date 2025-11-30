{ config, pkgs, secrets, hostname, username, lib, ... }:

{
	imports = [
		../../common/common.nix
		../../hardware/raspberrypi-hardware.nix

		./glance.nix
	];

	environment.systemPackages = lib.mkAfter (with pkgs; [
		jellyfin
		jellyfin-web
		jellyfin-ffmpeg

		ntfs3g
	]);

	hardware.graphics = {
		enable = true;	
	};

	networking = {
		hostName = hostname;
		wireless = {
			enable = true;
			networks."${secrets.wifiSSID}".psk = secrets.wifiPasswd;
			interfaces = [ "wlan0" ];
		};

		firewall = {
			allowedTCPPorts = [ 1111 3000 2222 8096 4444 80 443 ];
		};
	};

	services.avahi = {
		enable = true;
		nssmdns4 = true;
		publish.enable = true;
		publish.domain = true;
		publish.addresses = true;
	};

	services.jellyfin = {
		enable = true;
		openFirewall = true;
		user = "${username}";
	};

	services.forgejo = {
		enable = true;
		lfs.enable = true;

		database.type = "postgres";

		settings = {
			server = {
				DOMAIN = "${config.networking.hostName}.local";
				ROOT_URL = "http://${config.networking.hostName}.local:3000/";
				HTTP_PORT = 3000;
				SSH_DOMAIN = "${config.networking.hostName}.local";
				HTTP_ADDR = "0.0.0.0";
			};
			service = {
				DISABLE_REGISTRATION = true; # false only when registering admin for the first time
			};
		};
	};

	environment.etc."nextcloud-admin-pass".text = secrets.nextcloudAdminPassword;
	services.nextcloud = {
		enable = true;
		hostName = "${config.networking.hostName}.local";
		https = false; # since I'm on local network now I don't need https
		config = {
			adminuser = "admin";
			adminpassFile = "/etc/nextcloud-admin-pass";
			dbtype = "sqlite";
		};

		datadir = "/var/lib/nextcloud";	# where Nextcloud stores uploaded files
		settings = { # extra recommended PHP/Nextcloud config
			trusted_domains = [
				"${config.networking.hostName}.local"
				"localhost"
			];
			overwrite.cli.url = "http://${config.networking.hostName}.local";
			overwriteprotocol = "http";
		};
	};
}
