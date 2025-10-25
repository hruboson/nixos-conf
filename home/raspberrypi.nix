{ pkgs, lib, ... }:

{
	home.packages = lib.mkAfter (with pkgs; [
		
	]);

	# .CONFIG
	home.file.".config/" = {
		source = ./dotfiles;
		recursive = true;
	};

}
