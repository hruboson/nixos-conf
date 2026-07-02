# self refers to the output of our flake so we can use any modules we defined even in different directories
{ self, inputs, ... }: {
	flake.nixosModules.cumulusSystem = { config, pkgs, lib, hostname, username, ... }: 
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

	resticEnvFile = "/run/restic/secrets/restic.env";
	in {
		boot.loader.efi.canTouchEfiVariables = true;
		boot.loader.grub.enable = true;
		boot.loader.grub.device = "/dev/disk/by-id/ata-Samsung_SSD_840_EVO_250GB_S1DBNSAD910570F";
		boot.loader.grub.useOSProber = false; # Only nixos running on this server (no other system)

		boot.supportedFilesystems = [ "ntfs" ];

		networking = {
			hostName = "servernix";
			domain = "servernix.local";
			firewall = {
				trustedInterfaces = [ "tailscale0" ];
				allowedUDPPorts = [
					config.services.tailscale.port
				];

				allowedTCPPorts = [ #TODO delegate opening ports to each module
					21
					80 
					443
					1111 # Glance
					2020 # Forgejo
					3000 # Linkwarden
					4004 # Plikd
					6167 # Tuwunel
					7007 # Tandoor recipes
					8010 # Audiobookshelf
					8060 # Kavita
					8080 # Wordpress
					8096 # Jellyfin
					8112 # Deluge
					#8448 # Synapse Matrix
					43000 # Minecraft Vanilla
					43001 # Minecraft Papermc
				];
			};
		};

		hardware.i2c.enable = true;
		hardware.graphics = { enable = true; enable32Bit = true; };

		##########
		# DRIVES #
		##########

		fileSystems."/mnt/CUTUP" = {
			device = "/dev/disk/by-uuid/E45A03115A02E062";
			fsType = "ntfs3";
			options = [ "rw" "noatime" "uid=1000" "gid=100" ];
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

		fileSystems."/mnt/JAG" = {
			device = "/dev/disk/by-uuid/7882f925-ce5a-40c8-9972-b7e09a8d275e";
			fsType = "ext4";
			options = [ "noatime" "commit=60" "lazytime" ];
		};

		fileSystems."/mnt/JAY" = {
			device = "/dev/disk/by-uuid/46db1d4a-210a-43a1-81c6-a7c4484b8b51";
			fsType = "ext4";
			options = [ "noatime" "commit=60" "lazytime" ];
		};

		fileSystems."/mnt/BACARA" = {
			device = "/dev/disk/by-uuid/33cd8b9d-142a-43d4-bff9-3291365b5b7e";
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

		####################
		# FILE PERMISSIONS #
		####################
		systemd.tmpfiles.rules = [
			"d /run/restic/secrets 0750 ${username} users -"
			"f ${resticEnvFile} 0640 ${username} users - RESTIC_PASSWORD=${inputs.secrets.resticRepoPass}"
			"d /mnt/JARK/nextcloud 0755 nextcloud nextcloud - -"
			"d /mnt/HUSK/nextcloud-external 0755 nextcloud nextcloud - -"

			"d /mnt/CUTUP 0755 root root - -"
			"d /mnt/JARK 0755 root root - -"
			"d /mnt/HUSK 0755 root root - -"
			"d /mnt/JAG 0755 root root - -"
			"d /mnt/JAY 0755 root root - -"
			"d /mnt/BACARA 0755 root root - -"
		];

		#######################
		# BACKUPS DEFINITIONS #
		#######################

		services.restic.backups = {
			cutupToBacara = {
				paths = [ "/mnt/CUTUP" ];
				repository = "/mnt/BACARA/restic";
				initialize = true;       # auto-init repo if missing
					timerConfig = {
						OnCalendar = "*-*-01,15 02:00:00";  # every month 1st and 15th at 2AM
					};
				exclude = [];
				environmentFile = resticEnvFile;
			};

			jarkToJag = {
				paths = [ "/mnt/JARK" ];
				repository = "/mnt/JAG/restic";
				initialize = true;
				timerConfig = {
					OnCalendar = "*-*-01,15 02:00:00";
				};
				environmentFile = resticEnvFile;
			};

			huskToJay = {
				paths = [ "/mnt/HUSK" ];
				repository = "/mnt/JAY/restic";
				initialize = true;
				timerConfig = {
					OnCalendar = "*-*-01,15 02:00:00";
				};
				environmentFile = resticEnvFile;
			};
		};

		system.stateVersion = "25.05";
	};
}
