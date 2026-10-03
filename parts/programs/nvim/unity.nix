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

            extraPlugins = [ nvim-unity-sync ];

            extraConfigLua = /* lua */ ''
              -- ── UNITY ────────────────────────────────────────────────
              require("unity.plugin").setup()
            '';

            plugins = {
              # hide Unity's generated folders and .meta files
              nvim-tree.settings.filters.custom = [
                "Library"
                "Temp"
                "Logs"
                "obj"
                "%.meta$"
              ];

              telescope.settings.defaults.file_ignore_patterns = [
                "Library/.*"
                "Temp/.*"
                "obj/.*"
                "%.meta$"
              ];

              # C# (OmniSharp)
              lsp.servers.omnisharp = {
                rootMarkers = [
                  ".csproj"
                ];
              };
            };
          };
        };
    };
}
