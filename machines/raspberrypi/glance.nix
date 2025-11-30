{ config, secrets, pkgs, lib, ... }:

{
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
						sites = [
						{
							title = "Forgejo";
							url = "http://${config.networking.hostName}.local:3000";
							icon = "di:git";
							timeout = "10s";
							allow-insecure = true;
						}
						{
							title = "Jellyfin";
							url = "http://${config.networking.hostName}.local:8096";
							icon = "di:jellyfin";
							timeout = "15s";
							allow-insecure = true;
						}
						{
							title = "Nextcloud";
							url = "http://${config.networking.hostName}.local";
							icon = "di:nextcloud";
							timeout = "15s";
							allow-insecure = true;
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
					{
						type = "twitch-channels";
						channels = [ 
							"Wirtual"
							"forsen"
							"robcdee"
							"Mazarin1k"
							"GosuPeak"
							"capuchinbird_"
							"Xisuma"
						];
					}
					];
				}
				];
			}
			];
		};
	};
}
