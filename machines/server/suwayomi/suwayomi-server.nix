{ config, pkgs, lib, inputs, username, secrets, ... }:

{
	environment.etc."suwayomi/symlink-manga.sh" = {
		source = ./symlink-manga.sh;  # relative path to your script
		mode = "0755";
	};

	systemd.tmpfiles.rules = [
		"d /var/lib/suwayomi-server/local 0755 suwayomi suwayomi -"
	];

	environment.etc."suwayomi-pass".text = secrets.suwayomiPass;
	systemd.services."suwayomi-server".serviceConfig.ExecStartPre = "/etc/suwayomi/symlink-manga.sh"; # sources all manga defined in symlink-manga.sh to /var/lib/suwayomi-server/local
	services.suwayomi-server = {
		enable = true;
		openFirewall = true;

		settings = {
			server = {
				port = 8060;
				basicAuthEnabled = true;
				basicAuthUsername = "${username}";
				basicAuthPasswordFile = "/etc/suwayomi-pass";
			};
		};
	};
}
