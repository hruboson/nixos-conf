{ config, pkgs, lib, inputs, secrets, ... }:

let
	# https://gist.github.com/mjungk/292287dbad0ba168838ef5b248dd9d36
	# Time after idle until spindown (5 seconds * SPINDOWN_TIME).
	spindownScript = ''
		#!/bin/bash
		SPINDOWN_TIME="60"
		for device in /dev/sd[a-z]; do
			if [ "$(cat /sys/block/$(basename $device)/queue/rotational)" -eq 1 ]; then
				echo "Configuring spindown for HDD: $device"
				/run/current-system/sw/bin/hdparm -S $SPINDOWN_TIME $device
			fi
		done
	'';
in
{
	boot.supportedFilesystems = [ "ntfs" ];

	fileSystems."/mnt/CUTUP" = {
		device = "/dev/disk/by-uuid/E45A03115A02E062";
		fsType = "ntfs3";
		options = [ "rw" "noatime" "uid=1000" "gid=100" "big_writes" ];
	};

	fileSystems."/mnt/JARK" = {
		device = "/dev/disk/by-uuid/92e8d681-9ae5-4751-af4e-fc2144946cf7";
		fsType = "ext4";
		options = [ "noatime" "commit=60" "lazytime" ];
	};

	fileSystems."/mnt/HUSK" = {
		device = "/dev/disk/by-uuid/8e80a3fa-c9a9-4529-b7d3-9dc74bd45ff3";
		fsType = "ext4";
		options = [ "noatime" "commit=60" "lazytime" ];
	};

		environment.systemPackages = lib.mkAfter( with pkgs; [ 
			hdparm 
		]);

		environment.etc."spindownScript.sh".text = spindownScript;

		systemd.services.hdparm = {
			description = "Service to spin down HDDs after a specified time in idle.";
			wantedBy = [ "multi-user.target" "sleep.target" "post-resume.target" ];
			after = [ "network.target" "suspend.target" "post-resume.target" ];
			serviceConfig = {
				Type = "oneshot";
				User = "root";
				ExecStart = "${pkgs.bash}/bin/bash /etc/spindownScript.sh";
			};
		};
}
