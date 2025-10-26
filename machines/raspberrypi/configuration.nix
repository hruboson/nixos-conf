{ config, pkgs, secrets, ... }:

{
	imports = [
		../../common/common.nix
		../../hardware/raspberrypi-hardware.nix
	];

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
}
