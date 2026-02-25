{ config, pkgs, lib, ... }:

{
	nixpkgs.config.allowUnfree = true;

	# should fix kde unpopulated xdg mime apps menu
	environment.etc."/xdg/menus/applications.menu".text = builtins.readFile "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";

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
		jmtpfs libmtp android-tools # Media Transfer Protocol (for Android devices)

		# utils
		doublecmd
		filezilla
		kdePackages.dolphin kdePackages.ffmpegthumbs kdePackages.qtimageformats
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
		gthumb
		quodlibet
		spotify
		bambu-studio # 3d printing software for Bambulab printer
		vlc
		deluge
		obs-studio

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

