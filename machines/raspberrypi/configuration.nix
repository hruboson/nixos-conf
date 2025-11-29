{ config, pkgs, secrets, hostname, username, lib, ... }:

{
	imports = [
		../../common/common.nix
		../../hardware/raspberrypi-hardware.nix
	];

	environment.systemPackages = lib.mkAfter (with pkgs; [
		jellyfin
		jellyfin-web
		jellyfin-ffmpeg

		ntfs3g
	]);

	hardware.graphics = {
		enable = true;	
	};

	networking = {
		hostName = hostname;
		wireless = {
			enable = true;
			networks."${secrets.wifiSSID}".psk = secrets.wifiPasswd;
			interfaces = [ "wlan0" ];
		};

		firewall = {
			allowedTCPPorts = [ 1111 3000 2222 8096 4444 80 443 ];
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
		user = "${username}";
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

	environment.etc."nextcloud-admin-pass".text = secrets.nextcloudAdminPassword;
	services.nextcloud = {
		enable = true;
		hostName = "${config.networking.hostName}.local";
		https = false; # since I'm on local network now I don't need https
		config = {
			adminuser = "admin";
			adminpassFile = "/etc/nextcloud-admin-pass";
			dbtype = "sqlite";
		};

		datadir = "/var/lib/nextcloud";	# where Nextcloud stores uploaded files
		settings = { # extra recommended PHP/Nextcloud config
			trusted_domains = [
				"${config.networking.hostName}.local"
				"localhost"
			];
			overwrite.cli.url = "http://${config.networking.hostName}.local";
			overwriteprotocol = "http";
		};
	};

	services.glance =  {
		enable = true;
		openFirewall = true;
		settings = {
			server = {
				port = 1111;
				host = "0.0.0.0";
			};
			pages = [
			{
				name = "Home";
				columns = [ 
				{ # Left column (small)
					size = "small";
					widgets = [
					{ type = "calendar"; }
					{
						type = "custom-api";
						title = "Astronomy Picture of the Day";
						cache = "1d";
						url = "https://api.nasa.gov/planetary/apod?api_key=${secrets.apiNasaKey}";
						headers = {
							Accept = "application/json";
						};
						template = ''
						{{- if eq (.JSON.String "media_type") "image" -}}
						<div style="display:flex; flex-direction:column; align-items:center; width:100%; padding:8px; box-sizing:border-box;">
							<p class="color-primary" style="margin:0 0 8px; text-align:center;">
							<a 
							href="https://apod.nasa.gov/apod/astropix.html" 
							target="_blank" 
							rel="noopener noreferrer"
							style="color: inherit; text-decoration: none;"
							>
							{{ .JSON.String "title" }}
						</a>
							</p>
							<img
							src="{{ .JSON.String "url" }}"
							alt="{{ .JSON.String "title" }}"
							style="max-width:100%; height:auto; display:block; border-radius:4px;"
							/>
							<details style="width:100%; margin-top:12px;">
							<summary class="color-highlight size-h5" style="cursor:pointer;">
							Show Explanation
							</summary>
							<p class="color-highlight size-h5" style="margin-top:8px; text-align:left; line-height:1.4;">
							{{ .JSON.String "explanation" }}
						</p>
							</details>
							</div>
							{{- else -}}
						<p class="color-negative" style="text-align:center;">
							No image available today.
							</p>
							{{- end }}
						'';
					}
					];
				}
				{ # Center column
					size = "full";
					widgets = [
					{
						type = "server-stats";
						servers = [
						{ type = "local"; name = "NixOS on Raspberry Pi 3"; }
						];
						cache = "5s";
						disks = [ "/" ];
						cpu = true;
						memory = true;
						load = true;
					}
					{
						type = "monitor";
						title = "Services";
						cache = "1m";
						timeout = "15s";
						sites = [
						{
							title = "Forgejo";
							url = "http://${config.networking.hostName}.local:3000";
							icon = "di:git";
						}
						{
							title = "Jellyfin";
							url = "http://${config.networking.hostName}.local:8096";
							icon = "di:jellyfin";
						}
						{
							title = "Nextcloud";
							url = "http://${config.networking.hostName}.local:4444";
							icon = "di:nextcloud";
						}
						];
					}
					{
						type = "group";
						widgets = [
						{
							type = "reddit";
							subreddit = "nixos";
							show-thumbnails = true;
						}

						{
							type = "reddit";
							subreddit = "selfhosted";
							show-thumbnails = true;
						}
						{
							type = "reddit";
							subreddit = "datahoarder";
							show-thumbnails = true;
						}
						];
					}
					];
				}
				{ # Right column (small)
					size = "small";
					widgets = [
					{
						type = "weather";
						location = "Zlín";
						units = "metric";
						hour-format = "24h";
					}
					];
				}
				];
			}
			];
		};
	};
}
