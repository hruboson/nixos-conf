{ self, inputs, ... }: {
	flake.nixosModules.servicesDisks = { config, lib, pkgs, username, ... }: {
		services.udisks2.enable = true;
		
		environment.systemPackages = with pkgs; [
			udiskie
			gvfs
			ntfs3g
		];

		home-manager.users.${username} = {
			services.udiskie.enable = true;
			services.udiskie.settings = {
				automount = true; # automatically mount drives
				automount_options = ["rw" "uid=1000" "gid=100"]; # UID/GID matches user
				notify = true; # desktop notifications
				#file_manager = "dolphin.desktop"; # integrate with file manager
			};
		};
	};
}
