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
		package = pkgs.neovim-unwrapped;

		extraConfig = ''
			set clipboard=unnamedplus
			'';
	};

	programs.bashmount.enable = true;

	home.file.".bashrc".source = ../dotfiles/.bashrc;
	
	# .CONFIG
	home.file.".config/" = {
		source = ../dotfiles;
		recursive = true;
	};
	home.file.".config/nvim".source = nvim-conf;
}
