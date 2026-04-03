{ self, inputs, settings, ... }: {
	flake.homeModules.qemuHome = { pkgs, lib, ... }: {
		imports = [
			self.homeModules.commonHome
			self.homeModules.kittyHome
		];
	};
}
