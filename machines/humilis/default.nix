{
  self,
  inputs,
  settings,
  ...
}:
{
  flake.nixosConfigurations.humilis = inputs.nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";

    modules = [
      self.nixosModules.humilisConfiguration
      inputs.home-manager.nixosModules.home-manager
      inputs.nixos-hardware.nixosModules.raspberry-pi-3
    ];

    specialArgs = {
      inherit inputs self;
      username = settings.username;
      hostname = "humilis";
    };
  };

  flake.nixosConfigurations.humilisSdImage = inputs.nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";

    modules = [
      self.nixosModules.humilisConfiguration
      inputs.home-manager.nixosModules.home-manager
      "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix"

      {
        sdImage.compressImage = false;
      }
    ];

    specialArgs = {
      inherit inputs self;
      username = settings.username;
      hostname = "humilis";
    };
  };

  flake.packages.aarch64-linux.humilis-sd-image =
    self.nixosConfigurations.humilisSdImage.config.system.build.sdImage;
}
