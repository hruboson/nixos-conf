{ config, pkgs, lib, ... }:

{
	nixpkgs.config.allowUnfree = true;

	environment.systemPackages = lib.mkAfter (with pkgs; [
		# system
		wl-clipboard
		wayland-utils
		nwg-displays # Wayland-based compositors display setup
		ntfs3g   # NTFS read/write support
		gvfs     # Filesystem integration
		udiskie  # Auto-mount daemon
		playerctl # Audio control daemon
		polychromatic # Razer devices color management

		# utils
		doublecmd
		filezilla

		# img, video, audio
		gimp3
		oculante
		quodlibet
		spotify
		bambu-studio # 3d printing software for Bambulab printer

		# programming
		libgcc
		gh
		neovide

		# communications
		discord

		# games
		prismlauncher # minecraft foss launcher
	]);
}

