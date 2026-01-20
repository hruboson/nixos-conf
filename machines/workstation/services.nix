{ config, pkgs, lib, ... }:

{
	# System service for device detection
	services.udisks2.enable = true;

	# audio
	# set default with `wpctl set-default <id>`, find the id by running `wpctl status`
	#TODO find a way to set default audio output device declaratively
	services.pipewire = {
		enable = true;
		wireplumber.enable = true;
		alsa.enable = true;
		alsa.support32Bit = true;
		jack.enable = true;
		pulse.enable = true;
	};

	# bluetooth
	hardware.bluetooth = {
		enable = true;
		powerOnBoot = true;
	};

	services.avahi = { # enables .local address resolution
		enable = true;
		nssmdns4 = true;
		openFirewall = true;
		ipv4 = true;
		ipv6 = true;
	};

	services.power-profiles-daemon.enable = true;

}
