{ pkgs, lib, ... }:

{
	#programs.zsh.promptInit = ''
	#	PROMPT="%F{blue}[ws]%f %~ %# "
	#'';

	home.packages = lib.mkAfter (with pkgs; [
		firefox # todo replace with waterfox later
		kdePackages.filelight

		kdePackages.kclock
		kdePackages.sddm-kcm
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
}
