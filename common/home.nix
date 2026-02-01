{ pkgs, nvim-conf, ... }:

{
	home.stateVersion = "25.05";

	home.packages = with pkgs; [ 
		ripgrep 
		fzf 
		bashmount
	];

	# NEOVIM
	programs.neovim = {
		enable = true;
		defaultEditor = true;
	};

	programs.bashmount.enable = true;

	home.file.".bashrc".source = ../dotfiles/.bashrc;
	
	# .CONFIG
	home.file.".config/" = {
		source = ../dotfiles;
		recursive = true;
	};
	home.file.".config/USER_MANUAL.md".source = ../USER_MANUAL.md;
	home.file.".config/nvim".source = nvim-conf;
}
