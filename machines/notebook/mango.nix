{ config, pkgs, lib, inputs, ... }:

{
	imports = [ inputs.mangowc.nixosModules.mango ];

	programs.mango = {
		enable = true;
	};

	services.xserver.enable = false;
	security.polkit.enable = true;
	services.dbus.enable = true;
	hardware.graphics.enable = true;
	
	# QEMU-specific config
	services.xserver.videoDrivers = [ "virtio" ];
	environment.variables.WLE_NO_HARDWARE_CURSORS = "1";

	services.pipewire = {
		enable = true;
		wireplumber.enable = true;
		alsa.enable = true;
		pulse.enable = true;
	};

	environment.systemPackages = lib.mkAfter(with pkgs; [
		foot
		rofi
		waybar
		grim
		slurp
		swaybg
		swaynotificationcenter
		swayidle
		swaylock-effects
		wlogout

		wl-clipboard
		cliphist
		wl-clip-persist

		wlr-randr
		brightnessctl
		wlsunset

		pamixer
		sox
		sway-audio-idle-inhibit

		grim
		slurp
		satty

		swayosd
	]);

	# graphical login screen (greetd+tuigreet)
	services.greetd = {
		enable = true;
		settings = {
			default_session = {
				# border=yellow;text=cyan;prompt=cyan;time=yellow;input=yellow;container=black;button=cyan;title=yellow 
				command = ''
				${pkgs.tuigreet}/bin/tuigreet --time 
				--theme "border=yellow;text=cyan"
				--remember --remember-session --cmd mango";
				user = "greeter'';
			};
		};
	};

	# https://github.com/sjcobb2022/nixos-conf/blob/main/hosts/common/optional/greetd.nix
	systemd.services.greetd.serviceConfig = {
		Type = "idle";
		StandardInput = "tty";
		StandardOutput = "tty";
		StandardError = "journal";
		TTYReset = true;
		TTYYVHangup = true;
		TTYVTDisallocate = true;
	};

}
