{ config, pkgs, lib, inputs, username, secrets, ... }:

{
	services.tandoor-recipes = {
		enable = true;
		port = 7007;
		address = "0.0.0.0";
		database.createLocally = true;

		extraConfig = {
			MEDIA_ROOT = "/var/lib/tandoor-recipes/media";
			ALLOWED_HOSTS = "servernix.local,127.0.0.1,localhost";
			CSRF_TRUSTED_ORIGINS = "http://servernix.local:7007,http://127.0.0.1:7007";
			GUNICORN_MEDIA = "1";
		};
	};

	systemd.tmpfiles.rules = [
		"d /var/lib/tandoor-recipes/media 0750 tandoor_recipes tandoor_recipes -"
	];

	systemd.services.tandoor-recipes.serviceConfig.ReadWritePaths = [ 
		"/var/lib/tandoor-recipes/media" 
	];
}
