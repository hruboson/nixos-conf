{ config, pkgs, lib, ... }:

{
	virtualisation.docker.enable = true;
	environment.systemPackages = lib.mkAfter(with pkgs; [
		qemu
		quickemu
	]);
}
