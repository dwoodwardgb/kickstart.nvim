-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = false
vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.inccommand = "split"
vim.opt.scrolloff = 5
vim.opt.relativenumber = true
vim.wo.fillchars = "eob: "
vim.opt.completeopt = "menuone,preview"
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.ruler = true
vim.opt.hlsearch = true
vim.opt.linebreak = true
vim.opt.breakat = "^I!@*+;,./?"
vim.opt.wrap = false
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.o.confirm = true
-- for neotree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		{
			"NMAC427/guess-indent.nvim",
			opts = {},
		},
		{
			"neovim/nvim-lspconfig",
			config = function()
				vim.lsp.config("lua_ls", {
					on_init = function(client)
						if client.workspace_folders then
							local path = client.workspace_folders[1].name
							if
								path ~= vim.fn.stdpath("config")
								and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
							then
								return
							end
						end

						client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
							runtime = {
								-- Tell the language server which version of Lua you're using (most
								-- likely LuaJIT in the case of Neovim)
								version = "LuaJIT",
								-- Tell the language server how to find Lua modules same way as Neovim
								-- (see `:h lua-module-load`)
								path = {
									"lua/?.lua",
									"lua/?/init.lua",
								},
							},
							-- Make the server aware of Neovim runtime files
							workspace = {
								checkThirdParty = false,
								library = {
									vim.env.VIMRUNTIME,
									-- Depending on the usage, you might want to add additional paths
									-- here.
									-- '${3rd}/luv/library'
									-- '${3rd}/busted/library'
								},
								-- Or pull in all of 'runtimepath'.
								-- NOTE: this is a lot slower and will cause issues when working on
								-- your own configuration.
								-- See https://github.com/neovim/nvim-lspconfig/issues/3189
								-- library = {
								--   vim.api.nvim_get_runtime_file('', true),
								-- }
							},
						})
					end,
					settings = {
						Lua = {},
					},
				})
				vim.lsp.enable("gopls")
				vim.lsp.enable("lua_ls")
				vim.lsp.enable("nim_langserver")
				vim.lsp.enable("ts_ls")
			end,
		},
		{
			"nvim-treesitter/nvim-treesitter",
			branch = "master",
			lazy = false,
			build = ":TSUpdate",
			config = function(_, opts)
				require("nvim-treesitter.configs").setup(opts)
			end,
			opts = {
				ensure_installed = {
					"c",
					"lua",
					"vim",
					"vimdoc",
					"query",
					"markdown",
					"markdown_inline",
					"ruby",
					"typescript",
					"javascript",
					"tsx",
					"css",
					"scss",
					"nim",
					"zig",
					"html",
				},
				sync_install = true,
				auto_install = true,
				highlight = {
					enable = true,
					-- disable slow treesitter highlight for large files
					disable = function(lang, buf)
						local max_filesize = 500 * 1024 -- 100 KB
						local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
						if ok and stats and stats.size > max_filesize then
							return true
						end
					end,
					additional_vim_regex_highlighting = false,
				},
			},
		},
		{
			"echasnovski/mini.pick",
			opts = {},
		},
		{
			"nvim-tree/nvim-tree.lua",
			opts = {
				view = {
					side = "right", -- Sets the NvimTree to open on the right side
				},
				filters = {
					dotfiles = false,
				},
				renderer = {
					indent_markers = {
						enable = true,
					},
					icons = {
						web_devicons = {
							file = {
								enable = false,
								color = true,
							},
							folder = {
								enable = false,
								color = true,
							},
						},
						glyphs = {
							default = "",
							symlink = "",
							bookmark = "󰆤",
							modified = "●",
							hidden = "󰜌",
							folder = {
								arrow_closed = ">",
								arrow_open = "v",
								default = "",
								open = "v",
								empty = "",
								empty_open = "v",
								symlink = "",
								symlink_open = "v",
							},
							git = {
								unstaged = "✗",
								staged = "✓",
								unmerged = "!",
								renamed = "➜",
								untracked = "★",
								deleted = "",
								ignored = "◌",
							},
						},
					},
				},
			},
		},
		{
			"stevearc/conform.nvim",
			opts = {
				formatters_by_ft = {
					lua = { "stylua" },
					javascript = { "prettier", stop_after_first = true },
					typescript = { "prettier", stop_after_first = true },
					nim = { "nimpretty" },
				},
			},
		},
	},
})

-- FORMAT ON SAVE
local enabled_fts_for_format_on_save = {
	nim = true,
	javascript = true,
	typescript = true,
	json = true,
	lua = true,
}
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "*" },
	callback = function(args)
		local ft = vim.bo[args.buf].filetype
		if enabled_fts_for_format_on_save[ft] then
			vim.api.nvim_create_autocmd("BufWritePre", {
				pattern = "*",
				callback = function(args)
					require("conform").format({
						bufnr = args.buf,
						lsp_format = "fallback",
						timeout_ms = 500,
					})
				end,
			})
		end
	end,
})

vim.keymap.set("n", "<leader>w", ":bd #<CR>")
vim.keymap.set("n", "<leader>p", ":Pick files<CR>")
-- TODO: also figure out how to grep the current text under selection
vim.keymap.set("n", "<leader>f", ":Pick grep<CR>")
vim.keymap.set("n", "<leader><tab>", ":Pick buffers<CR>")
vim.keymap.set("n", "<leader>b", ":NvimTreeToggle<CR>")
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>[", vim.cmd.tabprev)
vim.keymap.set("n", "<leader>]", vim.cmd.tabnext)
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

vim.diagnostic.config({
	virtual_text = {
		enabled = true,
		-- current_line = true, -- Only show virtual text on the current line
	},
})
