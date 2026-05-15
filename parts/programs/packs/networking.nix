{ self, inputs, ... }: {
	flake.nixosModules.appPackNetworking = { config, lib, pkgs, username, ... }: {
		environment.systemPackages = with pkgs; [
			inetutils
		];

		services.tailscale.enable = true;
		 
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
