{ config, pkgs, lib, inputs, secrets, ... }:

{

	systemd.tmpfiles.rules = [
		"f /run/deluge/auth 0600 deluge deluge - localclient:${secrets.delugePass}:10"
	];

	services.deluge = {
		enable = true;
		declarative = true;
		authFile = "/run/deluge/auth";

		web = {
			enable = true;
			port = 8112;
		};
		
		config = {
			download_location = "/var/lib/deluge/_NEW/";
			#move_completed = true;
			#move_completed_path = "/var/lib/deluge/_NEW/";

			max_connections_global = 200;
			max_active_downloading = 5;
			max_upload_slots_global = 0;
			max_upload_speed = "0.0";
			max_upload_slots_per_torrent = 0;
			max_upload_speed_per_torrent = 0;
			stop_seed_at_ratio = true;
			stop_seed_ratio = "0.0";
		};
	};
}
