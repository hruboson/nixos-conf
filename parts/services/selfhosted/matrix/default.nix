{ self, inputs, ... }: {
  flake.nixosModules.selfhostedMatrix =
    {
      config,
      lib,
      pkgs,
      username,
      ...
    }:
    let
      fqdn = "${config.networking.hostName}.local";
    in
    {
      networking.firewall.allowedTCPPorts = [ 6167 ];

      sops.secrets.matrixRegistrationSecret = {
        owner = config.services.matrix-tuwunel.user;
        group = config.services.matrix-tuwunel.group;
        restartUnits = [ "tuwunel.service" ];
      };

      services.matrix-tuwunel = {
        enable = true;

        settings = {
          global = {
            server_name = fqdn;

            # Listen only on LAN
            address = [ "0.0.0.0" ];
            port = [ 6167 ]; # default for tuwunel

            # Disable federation completely
            allow_federation = false;
            allow_encryption = true;
            allow_registration = true;
            registration_token_file = config.sops.secrets.matrixRegistrationSecret.path;

            trusted_servers = [ ];
            max_request_size = 100000000; # 100 MB
            well_known = {
              client = "https://matrix.hrubos.dev";
              server = "matrix.hrubos.dev:443";
            };
          };
        };

        # keep default state dir
        stateDirectory = "matrix-tuwunel";
      };

      selfhosted.services.matrix.port = 6167;
    };
}
