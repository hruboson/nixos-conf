{ self, inputs, ... }: {
	flake.nixosModules.servicesBluetooth = { config, lib, pkgs, username, ... }: {
		hardware.bluetooth = {
			enable = true;
			powerOnBoot = true;
			settings = {
				General = {
					Experimental = true;
					FastConnectable = true;
				};
				Policy = {
					AutoEnable = true;
				};
			};
		};
	};
}
