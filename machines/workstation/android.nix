{ config, pkgs, lib, hostname, username, ... }:

{
	programs.adb.enable = true;
	virtualisation.waydroid.enable = true; # I just want to play TFT
}
