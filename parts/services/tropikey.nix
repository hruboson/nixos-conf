{ self, inputs, ... }: {
	flake.nixosModules.servicesTropikey = { config, lib, pkgs, username, ... }: {
		imports = [
        	inputs.tropikey.nixosModules.default
		];
		programs.tropikey = {
			enable = true;
			#enableSshPkcs11 = true;
		};
	};
}
