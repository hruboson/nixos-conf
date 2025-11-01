{ pkgs, lib, ... }:

{
	home.packages = lib.mkAfter (with pkgs; [
		w3m	
	]);

	# .CONFIG
	home.file.".config/" = {
		source = ./dotfiles;
		recursive = true;
	};
}
