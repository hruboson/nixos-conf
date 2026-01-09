{ config, pkgs, lib, inputs, username, secrets, ... }:

{
	services.komga = {
		enable = true;
		openFirewall = true;

		settings = {
			server = {
				port = 8060;
				host = "0.0.0.0";
			};
		};
	};
}
