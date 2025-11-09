{ pkgs, username, ... }:

{
	# USERS
	users.users.${username} = { # Define a user account. Don't forget to set a password with ‘passwd’.
		isNormalUser = true;
		extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
	};
}

