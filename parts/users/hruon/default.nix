{ self, inputs, ... }: {
	flake.nixosModules.users = { pkgs, lib, config, username, ... }: let 
		userMail = "hruboson@gmail.com";
		userName = "Ondřej Hruboš";
	in {
		users.groups.media = {}; # group for external drives that need both services and user access
		users.users.${username} = {
			isNormalUser = true;
			extraGroups = [ "wheel" "networkmanager" "video" "audio" "media" "adbusers" "dialout" ];
		};

		home-manager.users.${username} = {
			home.username = username;
			home.stateVersion = "26.05";  # set this to your current nixpkgs version and never change it

			programs.lazygit.enable = true;
			programs.git = {
				enable = true;
				settings = {
					credential.helper = "${pkgs.gh}/bin/gh auth git-credential";
					user = {
						name = userName;
						email = userMail;
						init.defaultBranch = "main";
						pull.rebase = true;
					};
				};
			};
			programs.jujutsu = {
				enable = true;
				settings = {
					user = {
						name = userName;
						email = userMail;
					};
				};
			};
		};
	};
}
