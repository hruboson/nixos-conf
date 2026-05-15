{ self, inputs, settings, ... }: {
	flake.nixosConfigurations.eliska = inputs.nixpkgs.lib.nixosSystem {
		modules = [
			self.nixosModules.eliskaConfiguration
			inputs.home-manager.nixosModules.home-manager
		];

		specialArgs = {
			inherit inputs self;
			username = "eliska";
			hostname = "nixos";
		};
	};
}
