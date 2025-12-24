{ config, pkgs, secrets, hostname, username, lib, ... }:

{
	imports = [
		../../common/common.nix
		../../hardware/server-hardware.nix
		../raspberrypi/glance.nix
		./hypr.nix
	];

	# BOOT
	
	boot.loader.grub.enable = true;
	boot.loader.grub.device = "/dev/sda";
	boot.loader.grub.useOSProber = true;

	networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

	programs.wayvnc.enable = true;
	security.polkit.enable = true;

	environment.systemPackages = lib.mkAfter (with pkgs; [
		jellyfin
		jellyfin-web
		jellyfin-ffmpeg

		ntfs3g
	]);

	networking = {
		hostName = hostname;
		firewall = {
			allowedTCPPorts = [ 1111 3000 2020 2222 8096 4444 4004 80 443 5900 ];
		};
	};

	hardware.graphics = {
		enable = true;	
	};

	services.avahi = {
		enable = true;
		nssmdns4 = true;
		publish.enable = true;
		publish.domain = true;
		publish.addresses = true;
	};

	services.forgejo = {
		enable = true;
		lfs.enable = true;

		database.type = "postgres";

		settings = {
			server = {
				DOMAIN = "${config.networking.hostName}.local";
				ROOT_URL = "http://${config.networking.hostName}.local:2020/";
				HTTP_PORT = 2020;
				SSH_DOMAIN = "${config.networking.hostName}.local";
				HTTP_ADDR = "0.0.0.0";
			};
			service = {
				DISABLE_REGISTRATION = false; # false only when registering admin for the first time
			};
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

	### LINKWARDEN ###
	services.postgresql = {
		enable = true;

		ensureDatabases = [ "linkwarden" ];
		ensureUsers = [
		{
			name = "linkwarden";
			ensureDBOwnership = true;
		}
		];

		authentication = lib.mkOverride 10 ''
			local   all             all                                     trust
			host    linkwarden      linkwarden      127.0.0.1/32            trust
			'';
	};
	environment.etc."linkwarden/nextauth-secret" = {
		text = secrets.linkwardenPass;
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
}
