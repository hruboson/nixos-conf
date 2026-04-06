{ self, inputs, ... }: {
	flake.nixosModules.appPackSysutils = { config, lib, pkgs, username, ... }: {
		environment.systemPackages = with pkgs; [
			btop
			dysk
			mc
			mission-center

			ntfs3g
			gvfs
			udiskie
			playerctl

			# maybe move this to something like appPackAndroid
			jmtpfs libmtp android-tools usbutils libmtp go-mtpfs # Media Transfer Protocol (for Android devices)
		];

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
