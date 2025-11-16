{ pkgs, lib, ... }:

{
	home.packages = lib.mkAfter (with pkgs; [
		w3m	
	]);
}
