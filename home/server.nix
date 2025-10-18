{ pkgs, ... }:

{
	home.packages = with pkgs; [
		matrix-synapse
	];

	#programs.zsh.promptInit = ''
	#	PROMPT="%F{blue}[ws]%f %~ %# "
	#'';
}
