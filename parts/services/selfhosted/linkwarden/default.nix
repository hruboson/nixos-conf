{ self, inputs, ... }: {
  flake.nixosModules.selfhostedLinkwarden =
    {
      config,
      lib,
      pkgs,
      username,
      ...
    }:
    {
      sops.secrets.linkwarden_pass = {
        owner = "linkwarden";
        restartUnits = [ "linkwarden.service" ];
      };

      services.linkwarden = {
        enable = true;
        port = 3000;
        host = "0.0.0.0";
        openFirewall = true;

        enableRegistration = true;

        environment = {
          NEXTAUTH_URL = "http://${config.networking.hostName}.local:3000";
        };

        secretFiles = {
          NEXTAUTH_SECRET = config.sops.secrets.linkwarden_pass.path;
        };

        database = {
          port = 5432;
          host = "127.0.0.1";
          name = "linkwarden";
          user = "linkwarden";
        };
      };

      selfhosted.services.linkwarden.port = 3000;
    };
}
