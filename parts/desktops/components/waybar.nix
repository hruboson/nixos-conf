{ self, inputs, ... }: {
	flake.nixosModules.waybar = { config, lib, pkgs, username, ... }: {
		options.desktops.waybar = {
			enable = lib.mkEnableOption "Waybar status bar";
			style = lib.mkOption {
				type = lib.types.lines;
				default = "";
				description = "Custom CSS style for Waybar";
			};
			config = lib.mkOption {
				type = lib.types.attrs;  # Now expects an attribute set, not a string
				default = {};
				description = "Waybar configuration as Nix attribute set";
				example = lib.literalExpression ''
					{
						layer = "top";
						position = "top";
						modules-left = ["sway/workspaces"];
						clock.format = "{:%H:%M}";
					}
				'';
			};
		};

		config = lib.mkIf config.desktops.waybar.enable {
			environment.systemPackages = with pkgs; [
				waybar
				networkmanagerapplet
				libnotify
				upower
			];

			home-manager.users.${username} = {
				programs.waybar = {
					enable = true;
					style = config.desktops.waybar.style;
					settings = {
						mangoBar = config.desktops.waybar.config;
					};
				};
				
				wayland.windowManager.mango.autostart_sh = ''
					waybar
				'';
			};
		};
	};
}
