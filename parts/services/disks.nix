{ self, inputs, ... }: {
  flake.nixosModules.servicesDisks =
    {
      config,
      lib,
      pkgs,
      username,
      ...
    }:
    {
      services.udisks2.enable = true;
      environment.systemPackages = with pkgs; [
        udiskie
        gvfs
        ntfs3g
      ];

      services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="block", ENV{ID_FS_TYPE}=="ntfs", \
          ENV{ID_FS_UUID}!="B8ACE2A5ACE25CFE", \
          TAG+="systemd", ENV{SYSTEMD_WANTS}+="ntfsfix@%k.service"
      '';

      # fixes stuck bits from Windows fuckery
      systemd.services."ntfsfix@" = {
        description = "Clear NTFS dirty flag on /dev/%I";
        after = [ "graphical.target" ];
        serviceConfig = {
          Type = "oneshot";
          TimeoutStartSec = "15s"; # a stuck drive gets killed, not waited on
          ExecCondition = "${pkgs.bash}/bin/bash -c '! ${pkgs.util-linux}/bin/findmnt -S /dev/%I'"; # skip if already mounted
          ExecStart = "${pkgs.ntfs3g}/bin/ntfsfix -d /dev/%I";
        };
      };

      home-manager.users.${username} = {
        services.udiskie.enable = true;
        services.udiskie.settings = {
          automount = true; # automatically mount drives
          automount_options = [
            "rw"
            "uid=1000"
            "gid=100"
            "remove_hiberfile"
            "force"
          ]; # UID/GID matches user
          notify = true; # desktop notifications
          file_manager = "dolphin.desktop"; # integrate with file manager
        };
      };
    };
}
