{ pkgs, ... }:

{
	home.packages = (config.home.packages or []) ++ (with pkgs; [
		matrix-synapse
	]);

	#programs.zsh.promptInit = ''
	#	PROMPT="%F{blue}[ws]%f %~ %# "
	#'';
}
