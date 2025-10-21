{ pkgs, ... }:

{
	home.packages = (config.home.packages or []) ++ (with pkgs; [
		firefox
	]);

	#programs.zsh.promptInit = ''
	#	PROMPT="%F{blue}[ws]%f %~ %# "
	#'';
}
