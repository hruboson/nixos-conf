{ self, inputs, ... }: {
  # This module will make it available for any PC connected 
  # through local network or the tailscale network.
  flake.nixosModules.selfhostedLlamaNetworkLocal =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.selfhosted.llama;

      # Model registry lives next to this file: { default = "<name>"; models = { "<name>" = "/path.gguf"; }; }
      # Paths are plain strings, so the GGUFs are NOT copied into the Nix store.
      registry = builtins.fromJSON (builtins.readFile ./models.json);

      modelName = if cfg.model != null then cfg.model else registry.default;
      modelPath = registry.models.${modelName};

      package = cfg.package.override {
        vulkanSupport = cfg.backend == "vulkan";
        rocmSupport = cfg.backend == "rocm";
      };

      healthUrl = "http://127.0.0.1:${toString cfg.port}/health";
      metricsUrl = "http://127.0.0.1:${toString cfg.port}/metrics";

      waitForHealth = pkgs.writeShellScript "llama-wait-health" ''
        for _ in $(seq 1 ${toString cfg.startupTimeoutSeconds}); do
          ${pkgs.curl}/bin/curl -sf ${healthUrl} >/dev/null && exit 0
          sleep 1
        done
        echo "llama-server did not become healthy in time" >&2
        exit 1
      '';

      # llama-server has no idle shutdown, so watch its token counters and
      # stop the service after N minutes without any activity.
      idleWatcher = pkgs.writeShellScript "llama-idle-watcher" ''
        export PATH=${
          lib.makeBinPath [
            pkgs.curl
            pkgs.gawk
            pkgs.gnugrep
            pkgs.coreutils
          ]
        }
        limit=$(( ${toString cfg.idleStopMinutes} * 60 ))
        last=$(date +%s)
        prev=""
        while sleep 300; do # check every 5 mins
          m=$(curl -sf ${metricsUrl}) || continue
          cur=$(echo "$m" | grep -E '^llamacpp:(prompt_tokens_total|tokens_predicted_total) ' | awk '{s+=$2} END{print s+0}')
          busy=$(echo "$m" | awk '/^llamacpp:requests_processing /{print $2}')
          busy=''${busy:-0}
          if [ "$cur" != "$prev" ] || [ "''${busy%.*}" != "0" ]; then
            last=$(date +%s)
            prev=$cur
          fi
          if [ $(( $(date +%s) - last )) -ge "$limit" ]; then
            echo "idle for ${toString cfg.idleStopMinutes} min, stopping llama-server"
            ${config.systemd.package}/bin/systemctl --user stop llama-server.service
            exit 0
          fi
        done
      '';
    in
    {
      options.selfhosted.llama = {
        model = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          example = "qwen3.8-27B-IQ3_XXS";
          description = "Key from models.json. null = use the file's \"default\".";
        };

        backend = lib.mkOption {
          type = lib.types.enum [
            "vulkan"
            "rocm"
          ];
          default = "vulkan";
          description = "GPU backend for llama.cpp.";
        };

        package = lib.mkOption {
          type = lib.types.package;
          default = pkgs.llama-cpp;
          description = "Base llama-cpp package (backend flags are applied on top).";
        };

        host = lib.mkOption {
          type = lib.types.str;
          default = "127.0.0.1";
          description = "Bind address. Keep on loopback and let Caddy expose it.";
        };

        port = lib.mkOption {
          type = lib.types.port;
          default = 8080;
        };

        gpuLayers = lib.mkOption {
          type = lib.types.either lib.types.int lib.types.str;
          default = 99;
          description = "Value for -ngl (99 or \"all\" = offload everything).";
        };

        contextSize = lib.mkOption {
          type = lib.types.int;
          default = 16384;
        };

        extraArgs = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          example = [
            "-fa"
            "on"
            "--jinja"
            "--cache-type-k"
            "q8_0"
          ];
          description = "Extra llama-server arguments.";
        };

        startupTimeoutSeconds = lib.mkOption {
          type = lib.types.int;
          default = 300;
          description = "`systemctl --user start` blocks until /health is OK or this many seconds pass.";
        };

        idleStopMinutes = lib.mkOption {
          type = lib.types.nullOr lib.types.ints.positive;
          default = null;
          example = 60;
          description = "Stop the server after this many idle minutes. null = never.";
        };
      };

      config = {
        assertions = [
          {
            assertion = registry.models ? ${modelName};
            message = "selfhosted.llama.model = \"${modelName}\" is not listed in models.json";
          }
        ];

        # Not enabled at boot: start/stop with `systemctl --user start|stop llama-server`.
        # Start blocks until the model is loaded and /health returns OK.
        systemd.user.services.llama-server = {
          description = "llama.cpp server (${modelName}, ${cfg.backend})";
          wantedBy = [ ];
          after = [ "network.target" ];
          serviceConfig = {
            ExecStart = lib.escapeShellArgs (
              [
                "${package}/bin/llama-server"
                "--model"
                modelPath
                "--host"
                cfg.host
                "--port"
                (toString cfg.port)
                "-ngl"
                (toString cfg.gpuLayers)
                "-c"
                (toString cfg.contextSize)
                "--metrics"
              ]
              ++ cfg.extraArgs
            );
            ExecStartPost = "${waitForHealth}";
            TimeoutStartSec = cfg.startupTimeoutSeconds + 30;
            Restart = "on-failure";
            RestartSec = 5;
          };
        };

        # Pulled in by (and bound to) llama-server, so it only runs while the server does.
        systemd.user.services.llama-server-idle = lib.mkIf (cfg.idleStopMinutes != null) {
          description = "Stop llama-server after ${toString cfg.idleStopMinutes} idle minutes";
          wantedBy = [ "llama-server.service" ];
          bindsTo = [ "llama-server.service" ];
          after = [ "llama-server.service" ];
          serviceConfig.ExecStart = "${idleWatcher}";
        };

        selfhosted.services.llama.port = cfg.port;
      };
    };
}
