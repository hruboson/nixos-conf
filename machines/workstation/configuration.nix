{ config, pkgs, lib, ... }:

{
	imports = [
		../../common/common.nix
		../../hardware/workstation-hardware.nix
	];

	# BOOT
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	networking.hostName = "hruon-nixos-ws";

	# DESKTOP ENVIRONMENT
	services.displayManager.sddm.enable = true;
	services.desktopManager.plasma6.enable = true;
	security.rtkit.enable = true;

	services.libinput.enable = true; # enable touchpad
	services.xserver = { # keyboard settings
		enable = true;
		layout = "cz,us";
		xkbVariant = "winkeys";
		xkbOptions = "grp:shift_space_toggle";
	};

	services.xserver.displayManager.sddm.settings = {
		X11 = {
			KeyboardLayout = "cz,us";
		};
	};

	## Excluded packages (should produce minimal KDE environment)
	environment.plasma6.excludePackages = with pkgs.kdePackages; [
		dolphin 		# file manager
		konsole			# terminal
		elisa			# music player
		# ocular		# document viewer (kept, this one is actually quite nice)
		kdenlive		# video editor
		k3b				# cd/dvd burner
		# gwenview		# image viewer (kept)
		kmail			# mail client
		#korganizer		# calendar (kept)
	];

	## DE-related packages
	environment.systemPackages = lib.mkAfter (with pkgs; [
			wl-clipboard
			wayland-utils
			kitty
	]);
}
