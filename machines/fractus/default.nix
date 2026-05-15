{ self, inputs, settings, ... }: {
	flake.nixosConfigurations.fractus = inputs.nixpkgs.lib.nixosSystem {
		modules = [
			self.nixosModules.fractusConfiguration
			inputs.home-manager.nixosModules.home-manager
		];

		specialArgs = {
			inherit inputs self;
			username = settings.username;
			hostname = "fractus";
		};
	};
}
