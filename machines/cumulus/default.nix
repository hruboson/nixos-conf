{ self, inputs, settings, ... }: {
	flake.nixosConfigurations.cumulus = inputs.nixpkgs.lib.nixosSystem {
		modules = [
			self.nixosModules.cumulusConfiguration
			inputs.home-manager.nixosModules.home-manager
		];

		specialArgs = {
			inherit inputs self;
			username = settings.username;
			hostname = "cumulus";
		};
	};
}
