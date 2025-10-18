{ pkgs, ... }:

{
	home.packages = with pkgs; [
		neofetch
	];

	programs.zsh.promptInit = ''
		PROMPT="%F{red}[pi]%f %~ %# "
	'';
}
