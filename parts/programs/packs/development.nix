{ self, inputs, ... }: {
	flake.nixosModules.appPackDev = { config, lib, pkgs, username, ... }: {
		imports = [
			self.nixosModules.nvim
		];

		environment.systemPackages = with pkgs; [
			gh
			libgcc
			neovide
		];

		virtualisation.docker.enable = true;

		home-manager.users.${username} = {
			# File types -> app associations
			# mimetype.io/all-types
			xdg.mimeApps = {
				enable = true;
				defaultApplications = {
					"text/plain" = 	"neovide.desktop";
				};
			};
		};
	};
}
