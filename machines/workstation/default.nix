{ self, inputs, settings, ... }: {
	flake.nixosConfigurations.workstation = inputs.nixpkgs.lib.nixosSystem {
		modules = [
			self.nixosModules.workstationConfiguration
			inputs.home-manager.nixosModules.home-manager
		];

		specialArgs = {
			inherit inputs self;
			username = settings.username;
			hostname = "worknix";
		};
	};
}
