{ pkgs, mainUsername, ... }:

{
	# USERS
	users.users.${mainUsername} = { # Define a user account. Don't forget to set a password with ‘passwd’.
		isNormalUser = true;
		extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
	};
}

