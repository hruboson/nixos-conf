{ self, inputs, ... }: {
  flake.nixosModules.desktopOptions =
    {
      config,
      lib,
      ...
    }:
    {
      options.desktops.session = lib.mkOption {
        type = lib.types.enum [
          "plasma"
          "mango"
        ];
        default = "plasma";
        description = "Default desktop session selected by SDDM.";
      };

      config = {
        services.displayManager.defaultSession = config.desktops.session;
      };
    };
}
