{ config, pkgs, ... }:

{
	imports = [
		../../common/common.nix
		../../hardware/raspberrypi-hardware.nix
	];

	networking = {
		hostName = "nixosrpi3";
		wireless = {
			enable = true;
			networks."NETWORK_NAME".psk = "NETWORK_PASSWORD";
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
