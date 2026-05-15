{ self, inputs, ... }: {
	flake.nixosModules.servicesPackHomeserver = { config, lib, pkgs, username, ... }: {
		services.avahi = { # enables .local address resolution
			enable = true;
			nssmdns4 = true;
			openFirewall = true;
			ipv4 = true;
			ipv6 = true;
		};
	};
}
