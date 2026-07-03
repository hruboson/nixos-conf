{ self, inputs, ... }: {
	flake.nixosModules.appPackDev = { config, lib, pkgs, username, ... }: {
		imports = [
			self.nixosModules.nvim
		];

		environment.systemPackages = with pkgs; [
			gh
			libgcc
			neovide
			filezilla
			mc

			jujutsu
			lazyjj
		];

		virtualisation.docker.enable = true;

		home-manager.users.${username} = {
			programs.lazygit.enable = true;
			programs.git = {
				enable = true;
				/* Add settings in your user module
				settings = { ... };*/
			};

			# File types -> app associations
			# mimetype.io/all-types
			xdg.mimeApps = {
				enable = true;
				defaultApplications = {
					"text/plain" = 	"neovide.desktop";
					"application/x-zerosize" = "neovide.desktop";
				};
			};
		};
	};
}
