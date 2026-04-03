{ self, inputs, ... }: {
	flake.nixosModules.users = { pkgs, lib, config, username, ... }: {
		users.groups.media = {}; # group for external drives that need both services and user access
		users.users.${username} = {
			isNormalUser = true;
			extraGroups = [ "wheel" "networkmanager" "video" "audio" "media" "adbusers" ];
		};
	};
}
