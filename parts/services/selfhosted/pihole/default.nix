{ self, inputs, ... }: {
  flake.nixosModules.selfhostedPihole =
    {
      config,
      lib,
      pkgs,
      username,
      ...
    }:
    {
      services.pihole-ftl = {
        enable = true;
        settings = {
          # See <https://docs.pi-hole.net/ftldns/configfile/>

          dns.upstreams = [
			config.selfhosted.lanIp
          ];
		  dns.interface = "lo";
		  dns.listeningMode = "BIND";
        };

        lists = [
          {
            url = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/pro.txt";
            type = "block";
            enabled = true;
            description = "hagezi blocklist";
          }
        ];
      };

      services.pihole-web = {
        enable = true;
        ports = [ "8443" ];
      };

      selfhosted.services.pihole.port = 8443;
    };
}
