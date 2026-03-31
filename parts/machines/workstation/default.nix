{ self, inputs, settings, ... }: {
	flake.nixosConfigurations.workstation = inputs.nixpkgs.lib.nixosSystem {
		modules = [
			self.nixosModules.workstationConfiguration

			inputs.home-manager.nixosModules.home-manager {
				home-manager.useGlobalPkgs = true;
				home-manager.useUserPackages = true;
				home-manager.users.${settings.username} = { 
					imports = [ self.homeModules.workstationHome ];
				};
				home-manager.extraSpecialArgs = { inherit inputs; };
			}
		];

		specialArgs = {
			inherit inputs self;
			inherit (settings) username;
			hostname = "worknix";
		};
	};
}
