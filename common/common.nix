
{ config, pkgs, ... }:

{
	imports = [
		./users.nix
		./packages.nix
	];

	# ENABLE FLAKES
	nix.settings.experimental-features = [ "nix-command" "flakes" ];

	## SOUND
	services.pulseaudio.enable = false;

	## TOUCHPAD
	services.libinput.enable = true;

	# LOCALES
	console = {
		font = "Lat2-Terminus16";
		keyMap = "cz-qwertz";
	};
	time.timeZone = "Europe/Prague";

	i18n.defaultLocale = "en_US.UTF-8";
	i18n.extraLocaleSettings = {
		LC_ADDRESS = "cs_CZ.UTF-8";
		LC_IDENTIFICATION = "cs_CZ.UTF-8";
		LC_MEASUREMENT = "cs_CZ.UTF-8";
		LC_MONETARY = "cs_CZ.UTF-8";
		LC_NAME = "cs_CZ.UTF-8";
		LC_NUMERIC = "cs_CZ.UTF-8";
		LC_PAPER = "cs_CZ.UTF-8";
		LC_TELEPHONE = "cs_CZ.UTF-8";
		LC_TIME = "cs_CZ.UTF-8";
	};


	# NETWORK
	#networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
	networking.firewall.enable = true;

	# USB DRIVES
	services.udisks2.enable = true; # enable backend, then in home manager configure udiskie (frontend)

	# Enable the OpenSSH daemon and ssh-agent with keys
	services.openssh.enable = true;
	programs.ssh.startAgent = true;

	# MISC
	programs.nix-ld.enable = true;

	# if build is too slow change this line to nix.optimise.automatic = true;
	nix.settings.auto-optimise-store = true; # optimise /nix/store space

	# garbage collector
	nix.gc = {
		automatic = true;
		options = "--delete-older-than 14d";
	};

	# SYSTEM

	# VERSION
	# This option defines the first version of NixOS you have installed on this particular machine,
	# and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
	# Most users should NEVER change this value after the initial install, for any reason,
	# even if you've upgraded your system to a new NixOS release.
	# This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
	# so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
	# to actually do that.
	# This value being lower than the current NixOS release does NOT mean your system is
	# out of date, out of support, or vulnerable.
	# Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
	# and migrated your data accordingly.
	# For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
	system.stateVersion = "25.11"; # Did you read the comment?
}
