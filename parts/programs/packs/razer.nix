{ self, inputs, ... }: {
	flake.nixosModules.appPackRazer = { config, lib, pkgs, username, ... }: {
		environment.systemPackages = with pkgs; [
			polychromatic
		];

		hardware.openrazer.enable = true;
		hardware.openrazer.users = ["${username}"];

		home-manager.users.${username} = {
			# File types -> app associations
			# mimetype.io/all-types
			xdg.mimeApps = {
				enable = true;
				defaultApplications = {
					
				};
			};
		};
	};
}
