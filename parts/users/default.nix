{ self, inputs, settings, ... }: {
	flake.nixosModules.users = { pkgs, lib, config, ... }: {
		users.groups.media = {}; # group for external drives that need both services and user access
		users.users.${settings.username} = {
			isNormalUser = true;
			extraGroups = [ "wheel" "networkmanager" "video" "audio" "media" "adbusers" ];
		};
	};
}
