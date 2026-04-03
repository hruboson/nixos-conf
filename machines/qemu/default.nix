{ self, inputs, settings, ... }: {
	flake.nixosConfigurations.qemu = inputs.nixpkgs.lib.nixosSystem {
		modules = [
			self.nixosModules.qemuConfiguration
			inputs.home-manager.nixosModules.home-manager
		];

		specialArgs = {
			inherit inputs self;
			username = settings.username;
			hostname = "qexin";
		};
	};
}
