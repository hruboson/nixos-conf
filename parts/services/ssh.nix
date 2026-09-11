{ self, inputs, ... }: {
  flake.nixosModules.servicesSSH =
    {
      config,
      lib,
      pkgs,
      username,
      ...
    }:
    let
      /*addAllKeys = pkgs.writeShellScript "ssh-add-all" ''
        set -eu
        export PATH=${pkgs.openssh}/bin:$PATH
        for f in "$HOME"/.ssh/*; do
          [ -f "$f" ] || continue
          case "$f" in
            *.pub|*known_hosts*|*config|*authorized_keys*) continue ;;
          esac
          # only add if it's a private key with NO passphrase
          if ssh-keygen -y -f "$f" -P "" >/dev/null 2>&1; then
            ssh-add "$f" </dev/null >/dev/null 2>&1 || true
          fi
        done
      '';*/
    in
    {
      /*systemd.user.services.ssh-add-all = {
        description = "Add all passphrase-less SSH keys to ssh-agent";
        wantedBy = [ "default.target" ];
        after = [ "ssh-agent.socket" ];
        requires = [ "ssh-agent.socket" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${addAllKeys}";
        };
      };*/

      home-manager.users.${username} = {
        programs.ssh = {
          enable = true;
        };

        /*programs.keychain = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
        };*/
      };
    };
}
