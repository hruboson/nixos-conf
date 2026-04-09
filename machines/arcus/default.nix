{ self, inputs, settings, ... }: {
	flake.nixosConfigurations.arcus = inputs.nixpkgs.lib.nixosSystem {
		modules = [
			self.nixosModules.arcusConfiguration
			inputs.home-manager.nixosModules.home-manager
		];

		specialArgs = {
			inherit inputs self;
			username = settings.username;
			hostname = "arcus";
		};
	};
}
