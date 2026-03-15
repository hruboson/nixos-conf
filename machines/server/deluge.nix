{ config, pkgs, lib, inputs, username, secrets, ... }:

{

	users.users.${username}.extraGroups = [ "media" ]; # add main user to media

	systemd.tmpfiles.rules = lib.mkIf true ([
		# ensure all necessary directories and files are created
		"d /srv/torrents 2775 deluge media -"
		"d /run/deluge 0750 deluge media -"
		"d /var/lib/deluge/.config/deluge 0750 deluge deluge -"
		"f /run/deluge/auth 0600 deluge deluge - localclient:${secrets.delugePass}:10"
	]);

	services.deluge = {
		enable = true;
		declarative = true;
		authFile = "/run/deluge/auth";
		group = "media"; # add deluge to media

		web = {
			enable = true;
			port = 8112;
		};
		
		config = {
			download_location = "/srv/torrents/";
			#move_completed = true;
			#move_completed_path = "/srv/torrents/";

			max_connections_global = 200;
			max_active_downloading = 5;
			max_upload_slots_global = 0;
			max_upload_speed = 0.0;
			max_upload_slots_per_torrent = 0;
			max_upload_speed_per_torrent = 0;
			stop_seed_at_ratio = true;
			stop_seed_ratio = 0.0;
		};
	};
}
