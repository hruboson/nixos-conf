{ self, inputs, settings, ... }: {
	flake.homeModules.commonHome = { pkgs, lib, ... }: {
		home.username = settings.username;
		home.stateVersion = "25.11";  # set this to your current nixpkgs version and never change it

		programs.lazygit.enable = true;
		programs.git = {
			enable = true;
			settings = {
				user = {
				    name = "Ondřej Hruboš";
				    email = "hruboson@gmail.com";
				    init.defaultBranch = "main";
				    pull.rebase = true;
				};
		    };
		};
	};
}
