{ pkgs, lib, ... }:

{
	home.packages = lib.mkAfter (with pkgs; [
		firefox

		kdePackages.kclock
		kdePackages.sddm-kcm
	]);

	#programs.zsh.promptInit = ''
	#	PROMPT="%F{blue}[ws]%f %~ %# "
	#'';
}
