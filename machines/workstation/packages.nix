{ config, pkgs, lib, ... }:

{
	nixpkgs.config.allowUnfree = true;

	environment.systemPackages = lib.mkAfter (with pkgs; [
		# system
		wl-clipboard
		wayland-utils

		# img, video, audio
		gimp3

		# programming
		libgcc
	]);
}

