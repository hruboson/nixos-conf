{ config, pkgs, lib, hostname, username, inputs, ... }:

{
	programs.adb.enable = true;
	virtualisation.waydroid.enable = true;
	services.dbus.enable = true;
	environment.systemPackages = lib.mkAfter(with pkgs; [ 
		nur.repos.ataraxiasjel.waydroid-script 
	]);
	# After installing this for the first time, run:
	# sudo waydrdoid init
	# sudo waydroid-script
		# Select Android 13, Install, mark everything with space
		# Enter to install
	# Start waydroid session with `waydroid session start`
	# Find TFT on Google Play Store and install it, log in using Riot Games account
}
