{ self, inputs, ... }: {
    flake.nixosModules.nvim = { pkgs, lib, username, ... }:
    let
        home = { pkgs, lib, config, ... }: {
            imports = [ inputs.nixvim.homeModules.nixvim ];

            programs.nixvim = {
                enable = true;
                defaultEditor = true;
                viAlias = true;
                vimAlias = true;

				colorschemes.vague.enable = true;

                globals = {
                    mapleader = " ";
                    maplocalleader = "\\";
                    loaded_netrw = 1;
                    loaded_netrwPlugin = 1;
                    nvim_tree_respect_buf_cwd = 1;
                };

                opts = {
                    clipboard = "unnamedplus";
                    number = true;
                    relativenumber = true;
                    mouse = "a";
                    incsearch = true;
                    ignorecase = true;
                    smartcase = true;
                    hlsearch = true;
                    wrap = false;
                    shiftwidth = 4;
                    tabstop = 4;
                    termguicolors = true;
                    undofile = true;
                    inccommand = "nosplit";
                    scrolloff = 10;
                    mousemoveevent = true;
                    fillchars = {
                        eob = " ";
                        fold = " ";
                        foldopen = "󰅀";
                        foldsep = " ";
                        #foldclose = "";
                    };
                    foldcolumn = "1";
                    foldlevel = 20;
                    foldlevelstart = 20;
                    foldenable = true;
                };

                plugins = {
					dashboard.enable = true;
					lazygit.enable = true;
					
                    treesitter = {
                        enable = true;
                        settings = {
                            highlight = {
                                enable = true;
                                additional_vim_regex_highlighting = true;
                            };
                            indent.enable = false;
                            auto_install = false;
                        };
                    };
					nvim-tree = {
						enable = true;
						settings = {
							view = {
								width = 30;
								preserve_window_proportions = true;
								cursorline = false;
							};
							renderer.group_empty = true;
							filters = {
								dotfiles = false;
								custom = [ "node_modules" ".venv" "__pycache__" "build" ];
							};
							git.ignore = false;
							auto_reload_on_write = true;
							on_attach = {
								__raw = ''
									function(bufnr)
									local api = require("nvim-tree.api")
									api.config.mappings.default_on_attach(bufnr)

									-- Rebind change-root from C to <leader>cc
									vim.keymap.del("n", "C", { buffer = bufnr })
									vim.keymap.set("n", "<leader>cc", api.tree.change_root_to_node,
											{ desc = "Change NvimTree root", buffer = bufnr, noremap = true, silent = true })

								-- Multi-move extension
									local marked_files = {}

								local function toggle_mark()
									local node = api.tree.get_node_under_cursor()
									if not node or node.type ~= "file" then return end
										if marked_files[node.absolute_path] then
											marked_files[node.absolute_path] = nil
												vim.notify("Unmarked: " .. node.name)
										else
											marked_files[node.absolute_path] = true
												vim.notify("Marked: " .. node.name)
												end
												end

												local function move_marked()
												local node = api.tree.get_node_under_cursor()
												if not node or node.type ~= "directory" then
													vim.notify("Cursor must be on a folder!", vim.log.levels.ERROR)
														return
														end
														local target_dir = node.absolute_path
														for path, _ in pairs(marked_files) do
															local filename = vim.fn.fnamemodify(path, ":t")
																local new_path = target_dir .. "/" .. filename
																vim.fn.rename(path, new_path)
																vim.notify("Moved " .. filename .. " → " .. target_dir)
																end
																marked_files = {}
								api.tree.reload()
									end

									local opts = { buffer = bufnr, noremap = true, silent = true, nowait = true }
								vim.keymap.set("n", "mm", toggle_mark,
										vim.tbl_extend("force", opts, { desc = "Mark/unmark file for move" }))
									vim.keymap.set("n", "mM", move_marked,
											vim.tbl_extend("force", opts, { desc = "Move marked files here" }))
									end
									'';						};
						};
					};

					web-devicons = {
						enable = true;
						autoLoad = true;
						settings = {
							color_icons = true;
						};
					};
				};

				keymaps = [
				{ mode = "n"; key = "<C-x>"; action = ":NvimTreeToggle<cr>"; options.desc = "Toggle NvimTree"; }
				{ mode = "n"; key = "<TAB>";   action = ":bn<cr>"; options.desc = "Next buffer"; }
				{ mode = "n"; key = "<S-Tab>"; action = ":bp<cr>"; options.desc = "Prev buffer"; }
				{ mode = "n"; key = "<leader>lg"; action = ":LazyGit<cr>"; options.desc = "Open lazygit"; }
				];

# ── COKELINE ─────────────────────────────────────────────────
				extraPlugins = with pkgs.vimPlugins; [
					nvim-cokeline
						plenary-nvim   # cokeline dependency
				];

				extraConfigLua = ''
					-- ── TREESITTER EXTRAS ────────────────────────────────────
					vim.api.nvim_set_hl(0, "@type", { link = "Keyword" })
					vim.filetype.add({ extension = { jison = "jison", jisonlex = "jisonlex" } })
					vim.treesitter.language.register("javascript", "jison")
					vim.treesitter.language.register("javascript", "jisonlex")

					-- ── COKELINE ─────────────────────────────────────────────
					local get_hex = require('cokeline.hlgroups').get_hl_attr
					local yellow = vim.g.terminal_color_3
					require('cokeline').setup({
							default_hl = {
							fg = function(buffer)
							return buffer.is_focused
							and get_hex('Normal', 'fg')
							or  get_hex('Comment', 'fg')
							end,
							bg = function() return get_hex('ColorColumn', 'bg') end,
							},
							sidebar = {
							filetype = { 'NvimTree', 'neo-tree' },
							components = {{
							text = function(buf) return buf.filetype end,
							fg = yellow,
							bg = function() return get_hex('NvimTreeNormal', 'bg') end,
							bold = true,
							}},
							},
							})


				-- close current buffer
					vim.keymap.set('n', '<leader>q', function()
							local target_buffer = require('cokeline.buffers').get_current()
							if not target_buffer then print('Current buffer not found'); return end
							target_buffer:delete()
							end, { desc = 'Close buffer' })
					'';
			};
		};

	home-static = { pkgs, lib, config, ... }: {
		programs.neovim = {
			enable = true;
			defaultEditor = true;
		};

		home.file.".config/nvim".source = inputs.nvim-conf;
	};
	in {
		home-manager.users.${username} = home;
#home-manager.users.${username} = home-static;
	};
}
