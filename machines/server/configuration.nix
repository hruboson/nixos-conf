{ config, pkgs, secrets, hostname, username, lib, ... }:

{
	imports = [
		../../common/common.nix
		../../hardware/server-hardware.nix
		./hypr.nix
	];

	# BOOT
	
	boot.loader.grub.enable = true;
	boot.loader.grub.device = "/dev/sda";
	boot.loader.grub.useOSProber = true;

	networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

	programs.wayvnc.enable = true;
	security.polkit.enable = true;

	environment.systemPackages = lib.mkAfter (with pkgs; [
		jellyfin
		jellyfin-web
		jellyfin-ffmpeg

		ntfs3g
	]);

	networking = {
		hostName = hostname;
		firewall = {
			allowedTCPPorts = [ 1111 3000 2222 8096 4444 4004 80 443 5900 ];
		};
	};
}
