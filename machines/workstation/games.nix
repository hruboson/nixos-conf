{ config, pkgs, lib, hostname, username, ... }:

{
	programs.gamemode.enable = true;
	programs.steam = {
		enable = true;
		remotePlay.openFirewall = true;
		dedicatedServer.openFirewall = true;
		extraCompatPackages = with pkgs; [
			proton-ge-bin
		];
	};
}
