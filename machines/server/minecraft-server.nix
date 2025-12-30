{ config, pkgs, lib, inputs, secrets, ... }:

{
	imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];
	nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

	### MINECRAFT SERVER ###
	services.minecraft-servers = {
		enable = true;
		eula = true;
		openFirewall = true;

		servers = {
			vanilla = {
				enable = true;

				# get UUIDs of player at mcuuid.net
				whitelist = {
					Shiftoss = "966c4864-da7b-48b9-b904-986d6bd0d117";
				};

				serverProperties = {
					server-port = 43000;
					difficulty = 3;
					gamemode = 0;
					max-players = 10;
					motd = "Vanilla Nix";
					white-list = true;
					allow-cheats = true;
				};

				jvmOpts = "-Xms2048M -Xmx4096M";
			};
			papermc = {
				enable = true;
				package = pkgs.paperServers.paper-1_21_4;

				# get UUIDs of player at mcuuid.net
				operators = {
					Shiftoss = {
						uuid = "966c4864-da7b-48b9-b904-986d6bd0d117";
						level = 3;
						bypassesPlayerLimit = true;
					};
				};

				serverProperties = {
					server-port = 43001;
					enable-rcon = true;
					"rcon.password" = "${secrets.papermcPass}";

					difficulty = 3;
					gamemode = 0;
					max-players = 10;
					motd = "Paper Nix";
					white-list = false;
					allow-cheats = true;
				};

				files = {
					"plugins/SharedHealth.jar" = pkgs.fetchurl {
						url = "https://hangarcdn.papermc.io/plugins/ArwenOC/TeamSharedHealth/versions/1.0.0/PAPER/SharedHealth-1.0.0.jar";
						hash = "sha256-AnvUNc8uQywxKOT/IpuiT2r1pSN+0pF/Bf4xkoBeWD4=";
					};

					"plugins/PluginPortal.jar" = pkgs.fetchurl {
						url = "https://hangarcdn.papermc.io/plugins/Flyte/PluginPortal/versions/2.2.2/PAPER/PluginPortal-2.2.2.jar";
						hash = "sha256-byDUeRfSx/WHsCYxXYyCrurj8NVMrvHiZecfQAe8Ea4=";
					};
					"plugins/Worlds.jar" = pkgs.fetchurl {
						url = "https://hangarcdn.papermc.io/plugins/TheNextLvl/Worlds/versions/3.11.0-mc1.21.4/PAPER/worlds-3.11.0-mc1.21.4-all.jar";
						hash = "sha256-3rfaAAiPBXCTTePQ4a82w1AhvSbR2tgJ6tdVrfF65cc=";
					};
				};

				jvmOpts = "-Xms2048M -Xmx4096M";
			};
		};
	};
}
