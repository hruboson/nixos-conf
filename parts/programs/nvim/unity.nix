{ inputs, ... }:
{
  flake.nixosModules.nvim-unity =
    { username, ... }:
    {
      home-manager.users.${username} =
        { pkgs, ... }:
        let
          nvim-unity-sync = pkgs.vimUtils.buildVimPlugin {
            pname = "nvim-unity-sync";
            version = "git";
            src = inputs.nvim-unity-sync;
          };

          nvimunity = pkgs.writeShellApplication {
            name = "nvimunity";
            text = ''
              SOCKET="$HOME/.cache/nvimunity.sock"
              FILE="''${1:-}"
              LINE="''${2:-1}"

              if [ -S "$SOCKET" ] && nvim --server "$SOCKET" --remote-expr "1" >/dev/null 2>&1; then
                nvim --server "$SOCKET" --remote "$FILE"
                nvim --server "$SOCKET" --remote-send "<cmd>$LINE<CR>"
              else
                rm -f "$SOCKET"
                exec kitty nvim --listen "$SOCKET" "+$LINE" "$FILE"
              fi
            '';
          };
        in
        {
          home.packages = [ nvimunity ];
          home.file.".local/bin/nvimunity".source = "${nvimunity}/bin/nvimunity";

          programs.nixvim = {
            extraPackages = with pkgs; [
              dotnet-sdk # OmniSharp needs an SDK for MSBuild project loading
              mono
            ];

            extraPlugins = [
              nvim-unity-sync
            ];

            extraConfigLua = /* lua */ ''
              -- ── UNITY ────────────────────────────────────────────────
              require("unity.plugin").setup()

              -- ── ROSLYN LOADING (fidget) ──────────────────────────────
              local roslyn = { handle = nil, initialized = false }

              local function roslyn_finish()
              	roslyn.initialized = true
              	if roslyn.handle then
              		roslyn.handle:finish()
              		roslyn.handle = nil
              	end
              end

              -- as soon as a C# file opens and Roslyn isn't ready yet, show a message
              vim.api.nvim_create_autocmd("FileType", {
              	pattern = "cs",
              	callback = function()
              		if roslyn.initialized or roslyn.handle then
              			return
              		end
              		roslyn.handle = require("fidget.progress").handle.create({
              			title = "Roslyn",
              			message = "Starting server…",
              			lsp_client = { name = "roslyn" },
              		})
              	end,
              })

              vim.api.nvim_create_autocmd("LspAttach", {
              	callback = function(ev)
              		local client = vim.lsp.get_client_by_id(ev.data.client_id)
              		if not client or client.name ~= "roslyn" or client._fidget_wrapped then
              			return
              		end
              		client._fidget_wrapped = true

              		if roslyn.handle then
              			roslyn.handle:report({ message = "Loading projects…" })
              		end

              		-- Roslyn sends this once all projects have loaded.
              		-- Wrap the existing handler instead of replacing it.
              		local method = "workspace/projectInitializationComplete"
              		local orig = client.handlers[method]
              		client.handlers[method] = function(...)
              			roslyn_finish()
              			if orig then
              				return orig(...)
              			end
              		end
              	end,
              })

              -- server stopped (e.g. you restarted it): reset so the message shows again
              vim.api.nvim_create_autocmd("LspDetach", {
              	callback = function(ev)
              		local client = vim.lsp.get_client_by_id(ev.data.client_id)
              		if client and client.name == "roslyn" and #vim.lsp.get_clients({ name = "roslyn" }) <= 1 then
              			roslyn.initialized = false
              			if roslyn.handle then
              				roslyn.handle:cancel()
              				roslyn.handle = nil
              			end
              		end
              	end,
              })
            '';
          };
        };
    };
}
