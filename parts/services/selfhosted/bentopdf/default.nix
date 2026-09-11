{ self, inputs, ... }: {
	flake.nixosModules.selfhostedBentoPDF = { config, lib, pkgs, username, ... }: {
		services.bentopdf = {
			enable = true;
			domain = "bentopdf.${config.networking.hostName}.local";

			nginx = {
				enable = true;
				#virtualHost = {
				#	listen = [
				#		{ addr = "0.0.0.0"; port = 8085; }
				#	];
				#	serverName = "${config.networking.hostName}.local";
				#};
			};
		};
	};
}
