{ pkgs, ... }:

{
	home.packages = with pkgs; [
		firefox
	];

	#programs.zsh.promptInit = ''
	#	PROMPT="%F{blue}[ws]%f %~ %# "
	#'';
}
