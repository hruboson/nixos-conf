{ config, pkgs, lib, ... }:

{
	boot.supportedFilesystems = [ "ntfs" ];

	fileSystems."/mnt/DELTA" = {
		device = "/dev/disk/by-uuid/B8ACE2A5ACE25CFE";
		fsType = "ntfs-3g"; # ntfs-3g is recommended over ntfs3 for more stability when sharing the drive between Windows and Linux systems
		options = [ "rw" "noatime" "nofail" "uid=1000" "gid=100" "x-systemd.automount" ]; # all options at https://www.mankier.com/5/systemd.mount or `man systemd.mount`
	};
}
