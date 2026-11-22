{ self, inputs, ... }: {
  flake.nixosModules.selfhostedLlamaLocal =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.services.llamaLocal;

      # models.json:
      # { "default": "name",
      #   "models": {
      #     "name":  { "path": "/x.gguf", "contextSize": 32768, "gpuLayers": 99, "extraArgs": ["--cache-type-k", "q8_0"] },
      #     "small": "/y.gguf"
      #   } }
      # Models are not copied to nix store
      registry = builtins.fromJSON (builtins.readFile ./models.json);

      modelName = if cfg.model != null then cfg.model else registry.default;
      entry = registry.models.${modelName};
      spec = if builtins.isString entry then { path = entry; } else entry;

      package = cfg.package.override {
        vulkanSupport = cfg.backend == "vulkan";
        rocmSupport = cfg.backend == "rocm";
      };

      # health/metrics are probed on loopback even if bound to 0.0.0.0
      probeHost =
        if
          builtins.elem cfg.host [
            "0.0.0.0"
            "::"
          ]
        then
          "127.0.0.1"
        else
          cfg.host;
      probeUrl = "http://${probeHost}:${toString cfg.port}";

      waitForHealth = pkgs.writeShellScript "llama-wait-health" ''
        export PATH=${
          lib.makeBinPath [
            pkgs.coreutils
            pkgs.curl
          ]
        }
        for _ in $(seq 1 ${toString cfg.startupTimeoutSeconds}); do
          # fail fast if llama-server died instead of waiting out the timeout
          kill -0 "$MAINPID" 2>/dev/null || { echo "llama-server exited during startup" >&2; exit 1; }
          curl -sf -m 2 -o /dev/null ${probeUrl}/health && exit 0
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
        while sleep 60; do
          m=$(curl -sf -m 5 ${probeUrl}/metrics) || continue
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
      options.services.llamaLocal = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Define the on-demand llama.cpp server (systemd user service).";
        };

        model = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          example = "gemma-3-12b";
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

        unitName = lib.mkOption {
          type = lib.types.str;
          default = "llama-server";
          description = "systemd user unit name (without .service).";
        };

        host = lib.mkOption {
          type = lib.types.str;
          default = "127.0.0.1";
          description = ''
            Bind address. There is no authentication, so only change this
            if you understand who can reach the port.
          '';
        };

        port = lib.mkOption {
          type = lib.types.port;
          default = 11838;
        };

        url = lib.mkOption {
          type = lib.types.str;
          readOnly = true;
          default = "http://${probeHost}:${toString cfg.port}";
          description = "Base URL of the server, for use by other config (editor plugins etc).";
        };

        gpuLayers = lib.mkOption {
          type = lib.types.either lib.types.int lib.types.str;
          default = 99;
          description = "Value for -ngl (99 or \"all\" = offload everything). Per-model override in models.json.";
        };

        contextSize = lib.mkOption {
          type = lib.types.int;
          default = 16384;
          description = "Total context (-c), shared across parallel slots. Per-model override in models.json.";
        };

        parallel = lib.mkOption {
          type = lib.types.ints.positive;
          default = 1;
          description = "Parallel slots (--parallel). 1 keeps the whole context for a single user.";
        };

        jinja = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Pass --jinja (apply the model's chat template; needed for tool calling).";
        };

        extraArgs = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          example = [
            "-fa"
            "on"
            "--cache-type-k"
            "q8_0"
          ];
          description = "Extra llama-server arguments, appended last (after per-model extraArgs).";
        };

        environment = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = { };
          example = {
            HSA_OVERRIDE_GFX_VERSION = "11.0.0";
          };
          description = "Extra environment variables for the server process.";
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

      config = lib.mkIf cfg.enable {
        assertions = [
          {
            assertion = registry.models ? ${modelName};
            message = "services.llamaLocal.model = \"${modelName}\" is not in models.json (available: ${lib.concatStringsSep ", " (builtins.attrNames registry.models)})";
          }
        ];

        # Not enabled at boot: start/stop with `systemctl --user start|stop llama-server`.
        # Start blocks until the model is loaded and /health returns OK.
        systemd.user.services.${cfg.unitName} = {
          description = "llama.cpp server (${modelName}, ${cfg.backend})";
          wantedBy = [ ];
          environment = cfg.environment;
          # don't reload a huge model in a tight loop if startup keeps failing
          unitConfig = {
            StartLimitIntervalSec = 600;
            StartLimitBurst = 3;
          };
          serviceConfig = {
            ExecStart = lib.escapeShellArgs (
              [
                "${package}/bin/llama-server"
                "--model"
                spec.path
                "--host"
                cfg.host
                "--port"
                (toString cfg.port)
                "-ngl"
                (toString (spec.gpuLayers or cfg.gpuLayers))
                "-c"
                (toString (spec.contextSize or cfg.contextSize))
                "--parallel"
                (toString cfg.parallel)
              ]
              ++ lib.optional cfg.jinja "--jinja"
              ++ lib.optional (cfg.idleStopMinutes != null) "--metrics"
              ++ (spec.extraArgs or [ ])
              ++ cfg.extraArgs
            );
            ExecStartPost = "${waitForHealth}";
            TimeoutStartSec = cfg.startupTimeoutSeconds + 30;
            Restart = "on-failure";
            RestartSec = 5;
          };
        };

        # Bound to llama-server, so it only runs while the server does.
        systemd.user.services.llama-server-idle = lib.mkIf (cfg.idleStopMinutes != null) {
          description = "Stop llama-server after ${toString cfg.idleStopMinutes} idle minutes";
          wantedBy = [ "${cfg.unitName}.service" ];
          bindsTo = [ "${cfg.unitName}.service" ];
          after = [ "${cfg.unitName}.service" ];
          serviceConfig.ExecStart = "${idleWatcher}";
        };
      };
    };
}
