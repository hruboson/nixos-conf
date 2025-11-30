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
						type = "search";
						search-engine = "duckduckgo";
					}
					{
						type = "bookmarks";
						groups = [
						{ # Productivity / Yellow
							title = "Productivity";
							color = "50 90 50";
							links = [
							{ title = "Gmail"; url = "https://mail.google.com/mail/u/1/"; icon = "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fstatic.vecteezy.com%2Fsystem%2Fresources%2Fpreviews%2F022%2F613%2F021%2Fnon_2x%2Fgoogle-mail-gmail-icon-logo-symbol-free-png.png&f=1&nofb=1&ipt=54fbd04122c0938a13ede90083e4ab1e53f522872f24062bad6a991a962cef54"; }
							{ title = "Moodle"; url = "https://moodle.utb.cz/my/"; icon = "https://www.google.com/s2/favicons?domain=moodle.utb.cz"; }
							{ title = "UTB"; url = "http://stag.utb.cz"; icon = "https://www.google.com/s2/favicons?domain=stag.utb.cz"; }
							];
						}
						{ # Development / Green
							title = "Development";
							color = "130 60 45";
							links = [
							{ title = "RPI Dashboard"; url = "http://nixosrpi3.local:1111"; icon = "https://www.google.com/s2/favicons?domain=nixosrpi3.local"; }
							{ title = "Github"; url = "https://github.com/hruboson"; icon = "https://www.google.com/s2/favicons?domain=github.com"; }
							{ title = "Portfolio"; url = "http://www.hrubos.dev/"; icon = "https://hrubos.dev/img/logo-courier-sm.ico"; }
							];
						}
						{ # Social / Blue
							title = "Social";
							color = "210 70 50";
							links = [
							{ title = "Mastodon"; url = "https://techhub.social/"; icon = "https://www.google.com/s2/favicons?domain=techhub.social"; }
							{ title = "Reddit"; url = "https://old.reddit.com/"; icon = "https://www.google.com/s2/favicons?domain=old.reddit.com"; }
							{ title = "Instagram"; url = "https://www.instagram.com/"; icon = "https://www.google.com/s2/favicons?domain=instagram.com"; }
							];
						}
						{ # Entertainment / Red
							title = "Entertainment";
							color = "0 75 50";
							links = [
							{ title = "YouTube"; url = "https://www.youtube.com/"; icon = "https://www.google.com/s2/favicons?domain=youtube.com"; }
							{ title = "Titch"; url = "https://www.twitch.tv/"; icon = "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fclipartcraft.com%2Fimages%2Ftwitch-logo-png-twitter.png&f=1&nofb=1&ipt=dd77af44814daaac82c721ad5d86a6e34ecafcfaf2ed12b9133d94d7cec93f71&ipo=images"; }
							{ title = "CSFD"; url = "https://www.csfd.cz/"; icon = "https://www.google.com/s2/favicons?domain=csfd.cz"; }
							{ title = "Movies"; url = "https://www.beech.watch/"; icon = "https://www.google.com/s2/favicons?domain=beech.watch"; }
							{ title = "Miruro"; url = "https://www.miruro.to"; icon = "https://www.google.com/s2/favicons?domain=miruro.to"; }
							{ title = "AL"; url = "https://anilist.co/"; icon = "https://www.google.com/s2/favicons?domain=anilist.co"; }
							{ title = "Letterboxd"; url = "http://letterboxd.com"; icon = "https://www.google.com/s2/favicons?domain=letterboxd.com"; }
							];
						}
						{ # Gaming / Light pink
							title = "Games";
							color = "310 70 65";
							links = [
							{ title = "Lichess"; url = "http://lichess.org"; icon = "https://www.google.com/s2/favicons?domain=lichess.org"; }
							{ title = "Chess.com"; url = "https://www.chess.com"; icon = "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fimages.chesscomfiles.com%2Fuploads%2Fv1%2Fimages_users%2Ftiny_mce%2FSamCopeland%2FphpmeXx6V.png&f=1&nofb=1&ipt=8761ef6305d20fff4bc2538f125a3ee514f036b762b0e879a59434e6d6486d62&ipo=images"; }
							{ title = "Typeracer"; url = "http://play.typeracer.com"; icon = "https://www.google.com/s2/favicons?domain=play.typeracer.com"; }
							{ title = "lolesports"; url = "https://lolesports.com/en-GB/"; icon = "https://www.google.com/s2/favicons?domain=lolesports.com"; }
							{ title = "valorantesports"; url = "https://valorantesports.com/"; icon = "https://www.google.com/s2/favicons?domain=valorantesports.com"; }
							];
						}
						{ # Other / Light grey
							title = "Other";
							color = "0 0 80";
							links = [
							{ title = "Zoom Earth"; url = "https://www.zoom.earth/"; icon = "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fzoom.earth%2Fassets%2Fimages%2Ficon-400.jpg&f=1&nofb=1&ipt=9672bf7b3ab9914afd3dad9ff596693da7fbfa4b760ea678cfa26cb1b62e7c17&ipo=images"; }
							{ title = "Trading212"; url = "https://www.trading212.com/"; icon = "https://www.google.com/s2/favicons?domain=trading212.com"; }
							{ title = "Messenger"; url = "https://www.messenger.com/"; icon = "https://www.google.com/s2/favicons?domain=messenger.com"; }
							];
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
