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
              pkgs.vimPlugins.omnisharp-extended-lsp-nvim
            ];

            plugins.lsp.servers.omnisharp = {
              settings = {
                RoslynExtensionsOptions = {
                  EnableAnalyzersSupport = true;
                  EnableImportCompletion = true;
                  EnableDecompilationSupport = true;
                };
              };

              extraOptions.handlers = {
                "textDocument/definition".__raw = "require('omnisharp_extended').definition_handler";
                "textDocument/typeDefinition".__raw = "require('omnisharp_extended').type_definition_handler";
                "textDocument/references".__raw = "require('omnisharp_extended').references_handler";
                "textDocument/implementation".__raw = "require('omnisharp_extended').implementation_handler";
              };
            };

            extraConfigLua = /* lua */ ''
              -- ── UNITY ────────────────────────────────────────────────
              require("unity.plugin").setup()
            '';
          };
        };
    };
}
