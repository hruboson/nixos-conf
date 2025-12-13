{ pkgs, lib, inputs, ... }:

{
	#programs.zsh.promptInit = ''
	#	PROMPT="%F{blue}[ws]%f %~ %# "
	#'';

	home.packages = lib.mkAfter (with pkgs; [
		home-manager

		firefox # todo replace with waterfox later
		kdePackages.filelight
	]);

	# PLASMA MANAGER
	programs.plasma = {
		enable = true;
		workspace = {
			theme = "breeze-dark";
			iconTheme = "Papirus";
			soundTheme = "freedesktop";

			splashScreen.theme = "a2n.kuro";
			windowDecorations = {
				library = "org.kde.kdecoraion2";
				theme = "__aurorae__svg__WillowDarkShader";
			};
		};
	};	

	xdg.configFile."sway/config".text = ''
		include ~/.config/sway/*.conf
	'';

	# HYPRLAND PLUGINS
	# currently managed in systemwide config
	/*wayland.windowManager.hyprland = {
		enable = true; # allows home-manager to configure hyprland
		package = inputs.hyprland.packages."${pkgs.system}".hyprland;
		plugins = [
			inputs.hyprland-plugins.packages."${pkgs.system}".hyprbars
			inputs.hyprland-plugins.packages."${pkgs.system}".borders-plus-plus
		];

		/*settings = {
			"plugin:borders-plus-plus" = {
				add_borders = 1;
				"col.border_1" = "rgb(ffffff)";
				"col.border_2" = "rgb(2222ff)";

				border_size_1 = 10;
				border_size_2 = -1;

				natural_rounding = "yes";
			};
			"plugin:hyprbars" = {
				bar_height = 38;
				bar_color = "rgb(141415)";
				col.text = "rgb(ffffff)";
		        bar_text_size = 12;
				bar_text_font = "Nerd Font Mono Bold";
				bar_button_padding = 12;
				bar_padding = 10;
				bar_precedence_over_border = true;
				hyprbars-button = [
					"\$color1, 20, , hyprctl dispatch killactive"
					"\$color3, 20, , hyprctl dispatch fullscreen 2"
					"\$color4, 20, _, hyprctl dispatch togglefloating"
				];
			};
		};
	};*/

	home.pointerCursor = let 
		getFrom = url: hash: name: {
			gtk.enable = true;
			x11.enable = true;
			name = name;
			size = 48;
			package = 
				pkgs.runCommand "moveUp" {} ''
				mkdir -p $out/share/icons
				ln -s ${pkgs.fetchzip {
					url = url;
					hash = hash;
				}} $out/share/icons/${name}
			'';
		};
	in
		getFrom 
		"https://github.com/polirritmico/Breeze-Dark-Cursor/releases/download/v1.0/Breeze_Dark_v1.0.tar.gz"
		"sha256-FgqS3rHJ4o5x4ONSaDZlQu1sFhefhWPk8vaBvURKZzY=" # get this hash by running nix store prefetch-file https://github/cursortheme/theme.tar.gz ... if this hash is wrong you wont be able to rebuild the system
		"Breeze-Dark";
}
