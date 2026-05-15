{ self, inputs, ... }: {
	flake.nixosModules.selfhostedPlikd = { config, lib, pkgs, username, ... }: {
		services.plikd = {
			enable = true;
			openFirewall = true;
		
			settings = {
				ListenPort = 4004;
				ListenAddress = "0.0.0.0";
				SslEnabled = false;
				DataBackend = "file";
				Directory = "/var/lib/plikd";
		
				FeatureAuthentication = "default";
			};
		};
	};
}
