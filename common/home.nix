{ pkgs, ... }:

{
	home.stateVersion = "25.05";

	home.packages = with pkgs; [ 
		ripgrep 
		fzf 
	];

	# NEOVIM
	programs.neovim = {
		enable = true;
		package = pkgs.neovim-unwrapped;

		extraConfig = ''
			set clipboard=unnamedplus
			'';
	};

	home.file.".config/nvim".source = pkgs.fetchFromGitHub{ # fetch config from github
		owner = "hruboson";
		repo = "nvim-conf";
		rev = "main";
		sha256 = "039cpic7brgm69h2dmnrf92vjxasqp6mns8z2vic8sqczhk2r23v";
	};
}
