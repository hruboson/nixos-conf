{ config, lib, pkgs, ... }:

{
	environment.systemPackages = with pkgs; [ # List packages installed in system profile.
		# You can use https://search.nixos.org/ to find more packages (and options).
		wget
		lazygit
		nix-ld
		nix-prefetch-git
		macchina # sysinfo fetcher
	];

	programs.zsh.enable = true;

	# GIT
	programs.git = {
		enable = true;
		config = {
			user.name = "Ondřej Hruboš";
			user.email = "hruboson@gmail.com";
			init.defaultBranch = "main";
			pull.rebase = true;
		};
	};

}
