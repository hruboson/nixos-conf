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
}
