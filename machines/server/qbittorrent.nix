{ config, pkgs, lib, inputs, username, secrets, ... }:

{
	users.groups.media = {};

	users.users.qbittorrent.extraGroups = [ "media" ];
	users.users.${username}.extraGroups = [ "media" ];

	systemd.tmpfiles.rules = lib.mkIf true ([
		"d /srv/torrents 2775 qbittorrent media -"
	]);

	services.qbittorrent = {
		enable = true;

		user = "qbittorrent";
		group = "qbittorrent";

		webuiPort = 8112;
		torrentingPort = 51413;
		openFirewall = true;

		serverConfig = {
			LegalNotice.Accepted = true;

			Preferences = {
				WebUI = {
					Username = "admin";
					AlternativeUIEnabled = true;
					RootFolder = "${pkgs.vuetorrent}/share/vuetorrent";
					Password_PBKDF2 = secrets.qbittorrentPassHash;
				};

				Downloads = {
					SavePath = "/srv/torrents/";
					TempPathEnabled = false;
					MaxActiveDownloads = 5;
				};

				Connection = {
					GlobalMaxConnections = 200;
					GlobalMaxUploads = 0;
					MaxUploadsPerTorrent = 0;
					UploadRateLimit = 1;
					UploadRateLimitPerTorrent = 1;
				};

				BitTorrent = {
					MaxRatioEnabled = true;
					MaxRatio = 0.0;
				};

				General = {
					Locale = "en";
				};
			};
		};
	};
}
