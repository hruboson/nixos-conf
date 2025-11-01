{ config, pkgs, secrets, mainUsername, lib, ... }:

{
	imports = [
		../../common/common.nix
		../../hardware/raspberrypi-hardware.nix
	];

	environment.systemPackages = lib.mkAfter (with pkgs; [
		jellyfin
		jellyfin-web
		jellyfin-ffmpeg
	]);

	hardware.graphics = {
		enable = true;	
	};

	networking = {
		hostName = "nixosrpi3";
		wireless = {
			enable = true;
			networks."${secrets.wifiSSID}".psk = secrets.wifiPasswd;
			interfaces = [ "wlan0" ];
		};

		firewall = {
			allowedTCPPorts = [ 3000 2222 8096 ];
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
		user = "${mainUsername}";
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
}
