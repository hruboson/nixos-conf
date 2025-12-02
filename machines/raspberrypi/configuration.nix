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
			allowedTCPPorts = [ 1111 3000 2222 8096 4444 4004 80 443 ];
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

	environment.etc."nextcloud-admin-pass".text = secrets.nextcloudPass;
	services.nextcloud = {
		enable = true;
		hostName = "${config.networking.hostName}.local";
		https = false; # since I'm on local network now I don't need https
		package = pkgs.nextcloud32;

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

	services.plikd = {
		enable = true;
		openFirewall = true;
	
		settings = {
			ListenPort = 4004;
			ListenAddress = "0.0.0.0";
			SslEnabled = false;
			DataBackend = "file";
			Directory = "/var/lib/plikd";
	
			FeatureAuthentication = "default";
		};
	};

	# In the end I could not get Gokapi to work, kept getting read-only filesystem error
	#services.gokapi =  {
	#	enable = true;
	#
	#	environment = {
	#		GOKAPI_CONFIG_FILE = "config.json";
	#
	#		GOKAPI_PORT = 4004;
	#		GOKAPI_DATA_DIR = "/var/lib/gokapi";
	#		GOKAPI_CONFIG_DIR = "/var/lib/gokapi"; # must be in writeable directory
	#	};
	#
	#	mutableSettings = true;
	#};

	# Couldn't get this running either - same issue as gokapi
	# PsiTransfer config file
	#environment.etc."psitransfer-config.json".source = pkgs.writeText "psitransfer-config.json" ''
	#	{
	#		"port": 4004,
	#		"listen": "0.0.0.0",
	#		"storage": "files",
	#		"uploadDir": "/var/lib/psitransfer/uploads",
	#		"maxFileSize": 0,
	#		"baseUrl": "http://${config.networking.hostName}.local:4004"
	#	}
	#'';

	## PsiTransfer system service
	#systemd.services.psitransfer = {
	#	description = "PsiTransfer file upload service";
	#	after = [ "network.target" ];
	#	wantedBy = [ "multi-user.target" ];

	#	serviceConfig = {
	#		Type = "simple";
	#		User = "psitransfer";
	#		Group = "psitransfer";
	#		
	#		ExecStart = "${pkgs.psitransfer}/bin/psitransfer --config /etc/psitransfer-config.json";
	#		PermissionsStartOnly = true; # prestart now runs as root
	#		Restart = "always"; # auto restart on crash
	#	};

	#	preStart = ''
	#		mkdir -p /var/lib/psitransfer
	#		chown psitransfer:psitransfer /var/lib/psitransfer
	#	'';
	#};
	#users.users.psitransfer = {
	#	isSystemUser = true;
	#	group = "psitransfer";
	#	home = "/var/lib/psitransfer";
	#};
	#users.groups.psitransfer = {};
}
