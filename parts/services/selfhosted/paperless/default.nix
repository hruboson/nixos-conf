{ self, inputs, ... }: {
  flake.nixosModules.selfhostedPaperless =
    {
      config,
      lib,
      pkgs,
      username,
      ...
    }:
	let
      fqdn = "paperless.${config.selfhosted.domain}";
      dataDir = "/mnt/JARK/paperless";
    in
    {

      sops.secrets.paperless_admin_pass = {
        owner = "paperless";
        restartUnits = [ "paperless-scheduler.service" ];
      };

      sops.templates."paperless.env" = {
        content = ''
          PAPERLESS_SECRET_KEY=${config.sops.placeholder.paperless_secret_key}
        '';
        restartUnits = [
          "paperless-web.service"
          "paperless-scheduler.service"
          "paperless-task-queue.service"
          "paperless-consumer.service"
        ];
      };

      services.paperless = {
        enable = true;
        address = "0.0.0.0";
        port = 28981;

        passwordFile = config.sops.secrets.paperless_admin_pass.path;
        environmentFile = config.sops.templates."paperless.env".path;

        mediaDir = "${dataDir}/media";
        consumptionDir = "${dataDir}/consume";
        consumptionDirIsPublic = true; # lets other users drop files in

        settings = {
          PAPERLESS_URL = "https://${fqdn}";
          PAPERLESS_OCR_LANGUAGE = "ces+eng";
          PAPERLESS_TIME_ZONE = "Europe/Prague";
          PAPERLESS_ADMIN_USER = "hruon";
          PAPERLESS_CONSUMER_RECURSIVE = true;
          PAPERLESS_OCR_USER_ARGS = {
            optimize = 1;
            pdfa_image_compression = "lossless";
          };
        };
      };

      selfhosted.services.paperless.port = 28981;
    };
}
