{ config, pkgs, lib, inputs, username, secrets, ... }:

{
	services.komga = {
		enable = true;
		openFirewall = true;
		port = 8060;

		settings = {
			server = {
				host = "0.0.0.0";
			};
		};
	};
}
