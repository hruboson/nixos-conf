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
				nu = true;
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
					foldclose = "";
				};

				# ufo folds
				foldcolumn = "1";
				foldlevel = 20;
				foldlevelstart = 20;
				foldenable = true;
			};

			plugins = {

				# CORE
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

				nvim-ufo.enable = true; # better folds
					nvim-autopairs.enable = true;

				# HANDY
				lazygit.enable = true;

				# PRETTY
				dashboard.enable = true;
				statuscol = {
					enable = true;
					settings = {
						relculright = false;
						segments = [
							{
								# folds
								text = [ { __raw = "require('statuscol.builtin').foldfunc"; } ];
								click = "v:lua.ScFa";
							}
							/*{
								# diagnostics
								sign = { __raw = "namespace = { 'diagnostic/signs' }, maxwidth = 2, auto = true"; };
								click = "v:lua.ScSa";
							}*/
							{
								# line numbers
								text = [ { __raw = "require('statuscol.builtin').lnumfunc"; } ];
								condition = [ true { __raw = "require('statuscol.builtin').not_empty"; } ];
								click = "v:lua.ScLa";
							}
						];
					};
				};

				# MISC

				# IDE (AUTOCOMPLETE, LSP, ...)
			};

			keymaps = [
			# INSERT
			{ mode = "i"; key = "<C-H>";   action = "<C-W>"; options.desc = "Ctrl+Backspace"; }
			{ mode = "i"; key = "<C-BS>";  action = "<C-W>"; options.desc = "Ctrl+Backspace (neovide)"; }
			{ mode = "i"; key = "<C-Del>"; action = "<C-o>\"_dw"; options.desc = "Ctrl+Delete"; }

			# NORMAL - navigation
			{ mode = "n"; key = "<TAB>";   action = ":bn<cr>"; options.desc = "Next buffer"; }
			{ mode = "n"; key = "<S-Tab>"; action = ":bp<cr>"; options.desc = "Prev buffer"; }
			{ mode = "n"; key = "<C-x>";   action = ":NvimTreeToggle<cr>"; options.desc = "Toggle NvimTree"; }
			{ mode = "n"; key = "<Esc>";   action = "<cmd>noh<CR>"; options.desc = "Clear highlight"; }
			{ mode = "n"; key = "U";       action = "<C-r>"; options.desc = "Redo"; }

			# NORMAL - LSP
			{ mode = "n"; key = "gD";          action = "<cmd>lua vim.lsp.buf.declaration()<CR>"; options.desc = "Go to declaration"; }
			{ mode = "n"; key = "gd";          action = "<cmd>lua vim.lsp.buf.definition()<CR>"; options.desc = "Go to definition"; }
			{ mode = "n"; key = "<leader>sr";  action = "<cmd>lua vim.lsp.buf.rename()<CR>"; options.desc = "Rename"; }
			{ mode = "n"; key = "<leader>ac";  action = "<cmd>lua vim.lsp.buf.code_action()<CR>"; options.desc = "Code action"; }
			{ mode = "n"; key = "qf";          action = "<cmd>lua vim.lsp.buf.code_action()<CR>"; options.desc = "Quick fix"; }

			# NORMAL - misc
			{ mode = "n"; key = "<leader>rme"; action = ":%s/\r//g<CR>"; options.desc = "Remove ^M carriage returns"; }

			# NORMAL - void deletes (don't yank on delete)
			{ mode = "n"; key = "d";  action = "\"_d"; }
			{ mode = "n"; key = "dd"; action = "\"_dd"; }
			{ mode = "n"; key = "D";  action = "\"_D"; }
			{ mode = "n"; key = "x";  action = "\"_x"; }
			{ mode = "n"; key = "X";  action = "\"_X"; }
			{ mode = "n"; key = "s";  action = "\"_s"; }
			{ mode = "n"; key = "S";  action = "\"_S"; }
			{ mode = "n"; key = "gx"; action = "\"_gx"; }

			# NORMAL - Telescope
			{ mode = "n"; key = "<leader>tf"; action = "<cmd>Telescope find_files<CR>"; options.desc = "Find files"; }
			{ mode = "n"; key = "<leader>tg"; action = "<cmd>Telescope live_grep<CR>"; options.desc = "Live grep"; }
			{ mode = "n"; key = "<leader>tb"; action = "<cmd>Telescope buffers<CR>"; options.desc = "Buffers"; }
			{ mode = "n"; key = "<leader>to"; action = "<cmd>Telescope oldfiles<CR>"; options.desc = "Old files"; }
			{ mode = "n"; key = "<leader>ts"; action = "<cmd>Telescope grep_string<CR>"; options.desc = "Grep string"; }
			{ mode = "n"; key = "<leader>tu"; action = "<cmd>Telescope undo<CR>"; options.desc = "Undo history"; }
			{ mode = "n"; key = "<leader>tc"; action = "<cmd>Telescope conflicts<CR>"; options.desc = "Git conflicts"; }
			{ mode = "n"; key = "<leader>tp"; action = "<cmd>Telescope neoclip plus<CR>"; options.desc = "Clipboard"; }
			{ mode = "n"; key = "<leader>lg"; action = "<cmd>LazyGit<cr>"; options.desc = "LazyGit"; }

			# VISUAL - indentation
			{ mode = "v"; key = "<TAB>"; action = ">gv"; options.desc = "Indent selection"; }
			{ mode = "v"; key = "U";     action = "<C-r>"; options.desc = "Redo"; }

			# VISUAL BLOCK - void deletes
			{ mode = "x"; key = "d";  action = "\"_d"; }
			{ mode = "x"; key = "dd"; action = "\"_dd"; }
			{ mode = "x"; key = "D";  action = "\"_D"; }
			{ mode = "x"; key = "x";  action = "\"_x"; }
			{ mode = "x"; key = "X";  action = "\"_X"; }
			{ mode = "x"; key = "s";  action = "\"_s"; }
			{ mode = "x"; key = "S";  action = "\"_S"; }
			{ mode = "x"; key = "gx"; action = "\"_gx"; }

			# TERMINAL
			{ mode = "t"; key = "<C-Esc>"; action = "<C-\\><C-n>"; options.desc = "Exit terminal mode"; }
			];

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
