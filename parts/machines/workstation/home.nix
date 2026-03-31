{ self, inputs, settings, ... }: {
	flake.homeModules.workstationHome = { pkgs, lib, ... }: {
		imports = [
			self.homeModules.commonHome
			self.homeModules.kittyHome
		];
	};
}
