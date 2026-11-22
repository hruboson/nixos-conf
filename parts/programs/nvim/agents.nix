{ ... }:
{
  flake.nixosModules.nvim-agents =
    { config, username, ... }:
    {
      home-manager.users.${username} =
        { pkgs, lib, ... }:
        let
          # `config` here is the NixOS config captured from the outer module.
          # `or null` keeps this working on hosts that don't import selfhostedLlamaLocal.
          llamaCfg = config.services.llamaLocal or null;
          llama = if llamaCfg != null && (llamaCfg.enable or true) then llamaCfg else null;
          local = llama != null;

          svc = if local then (llama.unitName or "llama-server") else "";
          llamaUrl = if local then (llama.url or "http://127.0.0.1:${toString llama.port}") else "";

          # helper: <leader>c<key> -> run a CodeCompanion command, gated on the AI being on
          mk =
            {
              mode ? "n",
              key,
              cmd,
              range ? false,
              desc,
            }:
            {
              inherit mode;
              key = "<leader>c${key}";
              action.__raw = "function() AI.run('${cmd}', ${builtins.toJSON range}) end";
              options = {
                inherit desc;
                silent = true;
              };
            };

          # ── Lua shared by every machine ──────────────────────────────
          # Without a local server the AI is simply always "on".
          commonLua = /* lua */ ''
            -- ── AI (CodeCompanion) ───────────────────────────────────
            local AI = { state = "${if local then "off" else "on"}" } -- off | starting | on | stopping
            _G.AI = AI

            function AI.set_state(s)
              AI.state = s
              vim.g.ai_state = s
              vim.g.ai_enabled = (s == "on")
            end
            AI.set_state(AI.state)

            local function guard()
              if vim.g.ai_enabled then return true end
              vim.notify("AI is " .. AI.state .. ". Run :AIOn (<leader>co)", vim.log.levels.WARN)
              return false
            end

            local function leave_visual()
              vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "x", false)
            end

            function AI.run(cmd, range)
              if not guard() then return end
              if range then
                leave_visual()
                vim.cmd("'<,'>" .. cmd)
              else
                vim.cmd(cmd)
              end
            end

            function AI.prompt()
              if not guard() then return end
              local visual = vim.fn.mode():match("[vV\22]")
              if visual then leave_visual() end
              local range = visual and "'<,'>" or ""
              vim.api.nvim_feedkeys(":" .. range .. "CodeCompanion ", "n", false)
            end
          '';

          # ── Lua only when a local llama-server exists ────────────────
          localLua = /* lua */ ''
            local svc = "${svc}"
            local url = "${llamaUrl}"
            local timeout_ms = 300000

            local function handle(msg)
            	return require("fidget.progress").handle.create({
            		title = "AI",
            		message = msg,
            		lsp_client = { name = "llama.cpp" },
            	})
            end

            local function health(cb)
            	vim.system({ "curl", "-sf", "-m", "2", "-o", "/dev/null", url .. "/health" }, {}, function(r)
            		vim.schedule(function()
            			cb(r.code == 0)
            		end)
            	end)
            end

            local function systemctl(action, cb)
            	vim.system({ "systemctl", "--user", action, svc }, { text = true }, function(r)
            		vim.schedule(function()
            			cb(r)
            		end)
            	end)
            end

            function AI.on()
            	if AI.state ~= "off" then
            		vim.notify("AI is " .. AI.state, vim.log.levels.INFO)
            		return
            	end
            	AI.set_state("starting")
            	local h = handle("Starting up...")

            	systemctl("start", function(r)
            		if r.code ~= 0 then
            			h:cancel()
            			AI.set_state("off")
            			vim.notify("Could not start " .. svc .. ": " .. (r.stderr or ""), vim.log.levels.ERROR)
            			return
            		end

            		local started, done = vim.uv.now(), false
            		local timer = vim.uv.new_timer()
            		local function finish(ok, err)
            			if done then
            				return
            			end
            			done = true
            			timer:stop()
            			timer:close()
            			if ok then
            				AI.set_state("on")
            				h:report({ message = "Connected" })
            				h:finish()
            			else
            				h:cancel()
            				AI.set_state("off")
            				vim.notify("AI failed to start: " .. err, vim.log.levels.ERROR)
            				systemctl("stop", function() end)
            			end
            		end

            		timer:start(
            			500,
            			1000,
            			vim.schedule_wrap(function()
            				if done then
            					return
            				end
            				if vim.uv.now() - started > timeout_ms then
            					finish(false, "timed out waiting for /health")
            					return
            				end
            				health(function(ok)
            					if ok then
            						finish(true)
            					end
            				end)
            			end)
            		)
            	end)
            end

            function AI.off()
            	if AI.state == "starting" then
            		vim.notify("AI is still starting, try again once it is up", vim.log.levels.WARN)
            		return
            	elseif AI.state ~= "on" then
            		vim.notify("AI is " .. AI.state, vim.log.levels.INFO)
            		return
            	end
            	AI.set_state("stopping") -- blocks the keymaps immediately
            	local h = handle("Shutting down...")
            	systemctl("stop", function(r)
            		AI.set_state("off")
            		if r.code ~= 0 then
            			h:cancel()
            			vim.notify("Could not stop " .. svc .. ": " .. (r.stderr or ""), vim.log.levels.ERROR)
            			return
            		end
            		h:report({ message = "Stopped" })
            		h:finish()
            	end)
            end

            -- pick up a server that is already running when Neovim starts
            vim.api.nvim_create_autocmd("VimEnter", {
            	once = true,
            	callback = function()
            		health(function(ok)
            			if ok and AI.state == "off" then
            				AI.set_state("on")
            			end
            		end)
            	end,
            })

            -- notice when the server disappears (idle stop, crash, manual stop)
            local sync = vim.uv.new_timer()
            sync:start(
            	30000,
            	30000,
            	vim.schedule_wrap(function()
            		if AI.state ~= "on" then
            			return
            		end
            		health(function(ok)
            			if not ok and AI.state == "on" then
            				AI.set_state("off")
            				vim.notify("AI server stopped (idle or crashed). :AIOn to restart", vim.log.levels.WARN)
            			end
            		end)
            	end)
            )
          '';
        in
        {
          programs.nixvim = {
            plugins.fidget.enable = lib.mkDefault true;
			plugins.vectorcode.enable = true;

            plugins.codecompanion = {
              enable = true;
              settings = {
                interactions = {
                  # any other module can override these with a plain assignment
                  # (for remote-only machines, change "anthropic" to what you use)
                  chat.adapter = lib.mkDefault (if local then "llama" else "anthropic");
                  inline.adapter = lib.mkDefault (if local then "llama" else "anthropic");
                };
                display.chat.window = {
                  layout = "vertical";
                  position = "right";
                  width = 0.2;
                  full_height = true;
                };

                extensions = {
                  vectorcode = {
                    opts = {
                      add_tool = true;
                      add_slash_command = true;
                    };
                  };
                };
              }
              // lib.optionalAttrs local {
                adapters.http.llama.__raw = ''
                                    function()
                                      return require("codecompanion.adapters").extend("openai_compatible", {
                                        formatted_name = "llama.cpp",
                                        env = {
                                          url = "${llamaUrl}",
                                          api_key = "llama", -- ignored by llama-server, sent as-is
                                        },
                                        schema = {
                                          -- single-model server: set the name, skip the /v1/models lookup
                                          model = { default = "local", choices = { "local" } },
                                        },
                  handlers = {
                    -- Qwen templates on llama.cpp reject multiple system messages once tools
                    -- are added, so merge them all into a single one at the top
                    form_messages = function(self, messages)
                      local compat = require("codecompanion.adapters.http.openai_compatible")

                      local system, rest = {}, {}
                      for _, m in ipairs(messages) do
                        if m.role == "system" and type(m.content) == "string" then
                          table.insert(system, m)
                        else
                          table.insert(rest, m)
                        end
                      end

                      if #system > 1 then
                        local parts = {}
                        for _, m in ipairs(system) do
                          table.insert(parts, m.content)
                        end
                        local merged = vim.deepcopy(system[1])
                        merged.content = table.concat(parts, "\n\n")
                        table.insert(rest, 1, merged)
                        messages = rest
                      end

                      return compat.handlers.form_messages(self, messages)
                    end,
                  },
                                      })
                                    end
                '';
              };
            };

            extraPackages = lib.optionals local [ pkgs.curl ]; # health check

            userCommands = lib.optionalAttrs local {
              AIOn = {
                command.__raw = "function() AI.on() end";
                desc = "Start llama-server and wait until ready";
              };
              AIOff = {
                command.__raw = "function() AI.off() end";
                desc = "Stop llama-server";
              };
            };

            keymaps = [
              (mk {
                key = "c";
                cmd = "CodeCompanionChat Toggle";
                desc = "AI: toggle chat";
              })
              (mk {
                key = "n";
                cmd = "CodeCompanionChat";
                desc = "AI: new chat";
              })
              (mk {
                key = "p";
                cmd = "CodeCompanionActions";
                desc = "AI: action palette";
              })
              (mk {
                mode = "v";
                key = "p";
                cmd = "CodeCompanionActions";
                range = true;
                desc = "AI: action palette";
              })
              (mk {
                mode = "v";
                key = "A";
                cmd = "CodeCompanionChat Add";
                range = true;
                desc = "AI: add selection to chat";
              })
              (mk {
                key = "r";
                cmd = "CodeCompanionCodeReview";
                desc = "AI: review changes";
              })
              (mk {
                key = "g";
                cmd = "CodeCompanion /commit";
                desc = "AI: commit message";
              })
              (mk {
                mode = "v";
                key = "e";
                cmd = "CodeCompanion /explain";
                range = true;
                desc = "AI: explain selection";
              })
              (mk {
                mode = "v";
                key = "f";
                cmd = "CodeCompanion /fix";
                range = true;
                desc = "AI: fix selection";
              })
              {
                mode = [
                  "n"
                  "v"
                ];
                key = "<leader>ci";
                action.__raw = "function() AI.prompt() end";
                options = {
                  desc = "AI: inline prompt";
                  silent = true;
                };
              }
            ]
            ++ lib.optionals local [
              {
                mode = "n";
                key = "<leader>co";
                action.__raw = "function() AI.on() end";
                options = {
                  desc = "AI: start server";
                  silent = true;
                };
              }
              {
                mode = "n";
                key = "<leader>cx";
                action.__raw = "function() AI.off() end";
                options = {
                  desc = "AI: stop server";
                  silent = true;
                };
              }
            ];

            extraConfigLua = commonLua + lib.optionalString local localLua;
          };
        };
    };
}
