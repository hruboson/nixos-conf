{ config, pkgs, secrets, hostname, username, lib, ... }:

{
	imports = [
		../../common/common.nix
		../../hardware/server-hardware.nix
		./drives.nix

		./deluge.nix
		./glance.nix
	];

	# BOOT
	
	boot.loader.grub.enable = true;
	boot.loader.grub.device = "/dev/sda";
	boot.loader.grub.useOSProber = false; # Only nixos running on this server (no other system)

	networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
	nixpkgs.config.allowUnfree = true; # Needed for minecraft-server

	powerManagement.cpuFreqGovernor = "powersave";
	services.tlp.enable = true;
	services.printing.enable = false;
	hardware.bluetooth.enable = false;
	powerManagement.powertop.enable = true;

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
			allowedTCPPorts = [ 
 				80 
				443
				1111 # Glance
				3000 # Linkwarden
				2020 # Forgejo
				8096 # Jellyfin
				8112 # Deluge
				4004 # Plikd
				43000 # Minecraft server
			];

			extraCommands = ''
				# Allow Deluge Web UI from local network only
				#iptables -A INPUT -p tcp --dport 8112 -s 192.168.2.0/24 -j ACCEPT
				#iptables -A INPUT -p tcp --dport 8112 -j DROP
				#ip6tables -A INPUT -p tcp --dport 8112 -j DROP
			'';
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

	users.users.${username}.extraGroups = [ "deluge" ];
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

	### MINECRAFT SERVER ###
	services.minecraft-server = {
		enable = true;
		eula = true;
		openFirewall = true;
		declarative = true;

		# get UUIDs of player at mcuuid.net
		whitelist = {
			Shiftoss = "966c4864-da7b-48b9-b904-986d6bd0d117";
		};

		serverProperties = {
			server-port = 43000;
			difficulty = 3;
			gamemode = 0;
			max-players = 10;
			motd = "NixOS Minecraft server!";
			white-list = true;
			allow-cheats = true;
		};

		jvmOpts = "-Xms2048M -Xmx4096M";
	};
}
