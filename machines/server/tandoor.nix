{ config, pkgs, lib, inputs, username, secrets, ... }:

{
	services.tandoor-recipes = {
		enable = true;
		port = 7007;
		address = "0.0.0.0";
		database.createLocally = true;
	};
}
