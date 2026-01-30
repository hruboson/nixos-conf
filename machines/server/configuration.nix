{ config, pkgs, secrets, hostname, username, lib, ... }:

{
	imports = [
		../../common/common.nix
		../../hardware/server-hardware.nix
		./drives.nix

		#./qbittorrent.nix
		#./kavita.nix
		#./suwayomi/suwayomi-server.nix

		./deluge.nix
		./glance.nix
		./matrix.nix
		./minecraft-server.nix
		./komga.nix
		./audiobookshelf.nix
	];

	# BOOT
	
	boot.loader.grub.enable = true;
	boot.loader.grub.device = "/dev/sda";
	boot.loader.grub.useOSProber = false; # Only nixos running on this server (no other system)

	networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
	nixpkgs.config.allowUnfree = true; # Needed for minecraft-server

	programs.wayvnc.enable = true;
	security.polkit.enable = true;

	environment.systemPackages = lib.mkAfter (with pkgs; [
		jellyfin
		jellyfin-web
		jellyfin-ffmpeg

		ntfs3g

		mc
	]);

	networking = {
		hostName = hostname;
		domain = "${hostname}.local";
		firewall = {
			allowedTCPPorts = [ 
 				80 
				443
				1111 # Glance
				2020 # Forgejo
				3000 # Linkwarden
				4004 # Plikd
				8010 # Audiobookshelf
				8060 # Kavita
				8096 # Jellyfin
				8112 # Deluge
				8448 # Synapse Matrix
				43000 # Minecraft Vanilla
				43001 # Minecraft Papermc
			];
		};
	};

	hardware.graphics.enable = true;

	services.postgresql = {
		enable = true;

		initialScript = pkgs.writeText "postgres-init.sql" ''
		CREATE USER "matrix-synapse";
		CREATE USER "linkwarden";

		-- Matrix Synapse MUST use C collation
		CREATE DATABASE "matrix-synapse"
		WITH OWNER = "matrix-synapse"
		ENCODING = 'UTF8'
		LC_COLLATE = 'C'
		LC_CTYPE = 'C'
		TEMPLATE = template0;

		-- Linkwarden can use defaults
		CREATE DATABASE linkwarden
		WITH OWNER = linkwarden;
		'';


		# Allow local Unix socket connections and TCP from localhost
		authentication = lib.mkOverride 10 ''
			local   all             all                                     trust
			host    all             all             127.0.0.1/32            trust
			host    all             all             ::1/128                 trust
		'';
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
