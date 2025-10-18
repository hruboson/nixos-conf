{ pkgs, ... }:

{
	home.packages = with pkgs; [
	];

	#programs.zsh.promptInit = ''
	#	PROMPT="%F{blue}[ws]%f %~ %# "
	#'';
}
