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
		p7zip
		peazip
		bottles
		scrcpy # Mirror and control Android device
		wayscriber # Live annotation tool, trigger by $mod s
		mission-center
		galaxy-buds-client

		# office
		libreoffice-fresh
		obsidian

		# img, video, audio
		gimp3
		oculante
		quodlibet
		spotify
		bambu-studio # 3d printing software for Bambulab printer
		vlc
		deluge

		# programming
		libgcc
		gh
		neovide

		qmk qmk-udev-rules dos2unix keymap-drawer

		# communications
		discord
		element-desktop

		# games
		prismlauncher # minecraft foss launcher
		osu-lazer-bin
		heroic
		pcsx2
	]);
}

