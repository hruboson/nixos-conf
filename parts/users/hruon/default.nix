{ self, inputs, ... }: {
	flake.nixosModules.users = { pkgs, lib, config, username, ... }: {
		users.groups.media = {}; # group for external drives that need both services and user access
		users.users.${username} = {
			isNormalUser = true;
			extraGroups = [ "wheel" "networkmanager" "video" "audio" "media" "adbusers" ];
		};

		home-manager.users.${username} = {
			home.username = username;
			home.stateVersion = "25.11";  # set this to your current nixpkgs version and never change it

			programs.lazygit.enable = true;
			programs.git = {
				enable = true;
				settings = {
					credential.helper = "${pkgs.gh}/bin/gh auth git-credential";
					user = {
						name = "Ondřej Hruboš";
						email = "hruboson@gmail.com";
						init.defaultBranch = "main";
						pull.rebase = true;
					};
				};
			};
		};
	};
}
