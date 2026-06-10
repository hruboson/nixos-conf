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
    {
      virtualisation.oci-containers = {
        backend = "docker";
        containers.wordpress = {
          image = "wordpress:latest";
          ports = [ "8080:80" ];
          volumes = [ "/var/lib/wordpress-data:/var/www/html" ];
          environment = {
            WORDPRESS_DB_HOST = "wordpress-db"; # container name, not localhost
            WORDPRESS_DB_USER = "wordpress";
            WORDPRESS_DB_PASSWORD = "changeme";
            WORDPRESS_DB_NAME = "wordpress";
          };
          extraOptions = [ "--network=wordpress-net" ];
          dependsOn = [ "wordpress-db" ]; # start db first
        };

        containers.wordpress-db = {
          image = "mariadb:11";
          volumes = [ "/var/lib/wordpress-db:/var/lib/mysql" ];
          environment = {
            MYSQL_ROOT_PASSWORD = "rootpass";
            MYSQL_DATABASE = "wordpress";
            MYSQL_USER = "wordpress";
            MYSQL_PASSWORD = "changeme";
          };
          extraOptions = [ "--network=wordpress-net" ];
        };
      };

      systemd.services.init-wordpress-network = {
        description = "Create wordpress-net docker network";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig.Type = "oneshot";
        script = ''
          ${pkgs.docker}/bin/docker network inspect wordpress-net &>/dev/null \
            || ${pkgs.docker}/bin/docker network create wordpress-net
        '';
      };

      systemd.services."docker-wordpress" = {
        after = [ "init-wordpress-network.service" ];
        requires = [ "init-wordpress-network.service" ];
      };
      systemd.services."docker-wordpress-db" = {
        after = [ "init-wordpress-network.service" ];
        requires = [ "init-wordpress-network.service" ];
      };

      services.vsftpd = {
        enable = true;
        writeEnable = true;
        localUsers = true;
        anonymousUser = false;
        extraConfig = ''
          		    pam_service_name=vsftpd
        '';
      };
      security.pam.services.vsftpd.enable = true;
    };
}
