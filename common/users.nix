{ pkgs, username, ... }:

{
	users.groups.media = {}; # Group for external drives that need both services and user access

	# USERS
	users.users.${username} = { # Define a user account. Don't forget to set a password with ‘passwd’.
		isNormalUser = true;
		extraGroups = [ "wheel" "media" ]; # Enable ‘sudo’ for the user.
	};
}

