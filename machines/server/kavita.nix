{ config, pkgs, lib, inputs, username, secrets, ... }:

{
	environment.etc."kavita/token.key" = {
		text = secrets.kavitaTokenKey;
		mode = "0600";
		user = "kavita";
		group = "kavita";
	};

	services.kavita = {
		enable = true;
		dataDir = "/var/lib/kavita";

		tokenKeyFile = "/etc/kavita/token.key";

		settings = {
			Port = 8060;
			IpAddresses = "0.0.0.0";
		};
	};
}
