{ self, inputs, ... }:
{
  flake.nixosModules.selfhostedWordpress =
    {
      config,
      lib,
      pkgs,
      username,
      ...
    }:
    let
      wpPort = 8080;
    in
    {
      services.wordpress = {
        sites."biltex" = {
          virtualHost = {
            listen = [
              {
                ip = "0.0.0.0";
                port = wpPort;
              }
            ];
          };
        };
      };
    };
}
