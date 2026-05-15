{ self, inputs, ... }: {
	flake.nixosModules.servicesBluetooth = { config, lib, pkgs, username, ... }: {
		services.blueman.enable = true;
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
