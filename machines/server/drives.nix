{ config, pkgs, lib, inputs, secrets, ... }:

{
	boot.supportedFilesystems = [ "ntfs" ];

	fileSystems."/mnt/CUTUP" = {
		device = "/dev/disk/by-uuid/E45A03115A02E062";
		fsType = "ntfs3";
		options = [ "rw" "noatime" "uid=1000" "gid=100" ];
	};

	fileSystems."/mnt/JARK" = {
		device = "/dev/disk/by-uuid/92e8d681-9ae5-4751-af4e-fc2144946cf7";
		fsType = "ext4";
		options = [ "noatime" ];
	};

	fileSystems."/mnt/HUSK" = {
		device = "/dev/disk/by-uuid/8e80a3fa-c9a9-4529-b7d3-9dc74bd45ff3";
		fsType = "ext4";
		options = [ "noatime" ];
	};
}
