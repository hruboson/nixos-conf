{ config, pkgs, lib, ... }:

{
	nixpkgs.config.allowUnfree = true;

	environment.systemPackages = lib.mkAfter (with pkgs; [
		wl-clipboard
		wayland-utils

		gimp3
	]);
}

