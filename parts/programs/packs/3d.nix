{ self, inputs, ... }: {
	flake.nixosModules.appPack3D = { config, lib, pkgs, username, ... }: {
		nixpkgs.config.allowUnfree = true;
		
		environment.systemPackages = with pkgs; [
			openscad
			orca-slicer
			#freecad -- I couldn't get even the simplest thing done with this, buggy as hell...
			blender
		];
	};
}
