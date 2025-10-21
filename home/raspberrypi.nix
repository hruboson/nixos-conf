{ pkgs, ... }:

{
	home.packages = (config.home.packages or []) ++ (with pkgs; [
		neofetch
	]);

	programs.zsh.promptInit = ''
		PROMPT="%F{red}[pi]%f %~ %# "
	'';
}
