{ self, inputs, ... }: {
	flake.nixosModules.appPack3D = { config, lib, pkgs, username, ... }: {
		nixpkgs.config.allowUnfree = true;
		
		environment.systemPackages = with pkgs; [
			openscad
			#freecad -- I couldn't get even the simplest thing done with this, buggy as hell...
			#blender -- dont need it for now, maybe later on
		];
	};
}
