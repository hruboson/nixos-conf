{ config, pkgs, lib, ... }:

{
	environment.systemPackages = lib.mkAfter (with pkgs; [
		wl-clipboard
		wayland-utils
		kitty

		gimp3
	]);
}

