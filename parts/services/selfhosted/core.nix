{ self, inputs, ... }:
{
  flake.nixosModules.selfhostedCore =
    { config, lib, pkgs, ... }:
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
        services.caddy.package = pkgs.caddy.withPlugins {
          plugins = [ "github.com/caddy-dns/cloudflare@v0.2.4" ];
          hash = "sha256-PWadA5qr/gR2qDcT8l8u1Xku7LM2HIfWTLOkzezCYy0=";
        };
        services.caddy.globalConfig = ''
          auto_https disable_redirects
		  email hruboson@gmail.com
        '';

        # Caddy: one vhost per registered service
		# - find local certificate in /var/lib/caddy/.local/share/caddy/pki/authorities/local/root.crt
        services.caddy.virtualHosts = lib.concatMapAttrs (
          _: svc:
          let
            host = "${svc.subdomain}.${config.selfhosted.domain}";
            upstream = "${svc.proto}://127.0.0.1:${toString svc.port}";
          in
          {
            "https://${host}" = {
			  # change the first 3 lines to tls internal for local certificates - then distribute them using the certificate module by connecting to the server ip: 192.168.X.Y:1234
              extraConfig = ''
                tls {
                	dns cloudflare {env.CF_API_TOKEN}
                }
                reverse_proxy ${upstream}
                ${svc.extraCaddyConfig}
              '';
            };

            "http://${host}" = {
              extraConfig = ''
                reverse_proxy ${upstream}
              '';
            };
          }
        ) config.selfhosted.services;
        systemd.services.caddy.environment.CF_API_TOKEN = inputs.secrets.cloudflareAPIToken;

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
