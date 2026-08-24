{ self, inputs, ... }:
{
  flake.nixosModules.selfhostedCore =
    { config, lib, ... }:
    with lib;
    {
      options.selfhosted = {
        domain = mkOption {
          type = types.str;
          default = "mydomain.net";
        };

        lanIp = mkOption {
          type = types.str;
          description = "LAN IP of this server";
        };

        tailscaleIp = mkOption {
          type = types.str;
          description = "Tailscale IP of this server (100.x.x.x)";
        };

        lanCidr = mkOption {
          type = types.str;
          default = "192.168.1.0/24";
        };

        upstreamDns = mkOption {
          type = types.listOf types.str;
          default = [
            "1.1.1.1"
            "8.8.8.8"
          ];
        };

        services = mkOption {
          default = { };
          type = types.attrsOf (
            types.submodule (
              { name, ... }: {
                options = {
                  subdomain = mkOption {
                    type = types.str;
                    default = name;
                  };
                  port = mkOption { type = types.port; };
                  proto = mkOption {
                    type = types.enum [
                      "http"
                      "https"
                    ];
                    default = "http";
                  };
                  extraCaddyConfig = mkOption {
                    type = types.lines;
                    default = "";
                  };
                };
              }
            )
          );
        };
      };

      config = {
        services.caddy.enable = true;
        /*services.caddy.package = pkgs.caddy.withPlugins {
          plugins = [ "github.com/caddy-dns/namecheap@latest" ];
          hash = "";
        };
        environment.etc."caddy-namecheap-creds".text = ''
          ${inputs.secrets.namecheapApiUser}
          ${inputs.secrets.namecheapApiKey}
        '';

        services.caddy.globalConfig = ''
          acme_dns namecheap {
            api_key {env.NAMECHEAP_API_KEY}
            user {env.NAMECHEAP_USER}
            client_ip {env.NAMECHEAP_CLIENT_IP}
          }
        '';

        systemd.services.caddy.serviceConfig.EnvironmentFile = "/etc/caddy-namecheap-env";
        environment.etc."caddy-namecheap-env".text = ''
          NAMECHEAP_API_KEY=${inputs.secrets.namecheapApiKey}
          NAMECHEAP_USER=${inputs.secrets.namecheapApiUser}
          NAMECHEAP_CLIENT_IP=${yourServerPublicIp}
        '';*/

        # Caddy: one vhost per registered service
        services.caddy.virtualHosts = lib.mapAttrs' (
          _: svc:
          lib.nameValuePair "${svc.subdomain}.${config.selfhosted.domain}" {
            extraConfig = ''
			  tls internal
              reverse_proxy ${svc.proto}://127.0.0.1:${toString svc.port}
              ${svc.extraCaddyConfig}
            '';
          }
        ) config.selfhosted.services;

        # DNS: wildcard for *.domain, fall through for apex/www
        services.unbound = {
          enable = true;
          settings.server = {
            interface = [
              config.selfhosted.lanIp
              config.selfhosted.tailscaleIp
            ];

			define-tag = ''"lan ts"'';

            access-control = [
              "${config.selfhosted.lanCidr} allow"
              "100.64.0.0/10 allow" # tailscale CGNAT range
              "127.0.0.0/8 allow"
              "::1 allow"
            ];

            access-control-view = [
              "${config.selfhosted.lanCidr} lan-view"
              "100.64.0.0/10 ts-view"
              "127.0.0.0/8 lan-view"
              "::1/128 lan-view"
            ];

            local-zone = [ ''"${config.selfhosted.domain}." transparent'' ];
          };

          settings.view = [
            {
              name = "lan-view";
              local-zone = [ ''"${config.selfhosted.domain}." transparent'' ];
              local-data = lib.mapAttrsToList (
                _: svc: ''"${svc.subdomain}.${config.selfhosted.domain}. IN A ${config.selfhosted.lanIp}"''
              ) config.selfhosted.services;
            }
            {
              name = "ts-view";
              local-zone = [ ''"${config.selfhosted.domain}." transparent'' ];
              local-data = lib.mapAttrsToList (
                _: svc: ''"${svc.subdomain}.${config.selfhosted.domain}. IN A ${config.selfhosted.tailscaleIp}"''
              ) config.selfhosted.services;
            }
          ];

          settings.forward-zone = [
            {
              name = ".";
              forward-addr = [ "192.168.2.1" ] ++ config.selfhosted.upstreamDns ;
            }
          ];
        };

        # unbound needs to bind after tailscale0 exists
        systemd.services.unbound.after = [ "tailscaled.service" ];
        systemd.services.unbound.wants = [ "tailscaled.service" ];
      };
    };
}
