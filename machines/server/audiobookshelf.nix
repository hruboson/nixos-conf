{ config, pkgs, lib, inputs, username, secrets, ... }:

{
	services.audiobookshelf = {
		enable = true;
		port = 8010;
		host = "0.0.0.0";
		openFirewall = true;
	};
}
