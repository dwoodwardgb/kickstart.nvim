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
vim.keymap.set("n", "<leader>[", vim.cmd.tabprev)
vim.keymap.set("n", "<leader>]", vim.cmd.tabnext)
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
-- for neotree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		{
			"neovim/nvim-lspconfig",
			config = function()
				vim.lsp.enable("gopls")
				vim.lsp.enable("lua_ls")
				vim.lsp.enable("nim_langserver")
				vim.lsp.enable("ts_ls")
			end,
		},
		{
			"nvim-treesitter/nvim-treesitter",
			opts = {
				-- A list of parser names, or "all" (the listed parsers MUST always be installed)
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

				-- Install parsers synchronously (only applied to `ensure_installed`)
				sync_install = false,

				-- Automatically install missing parsers when entering buffer
				-- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
				auto_install = true,

				-- List of parsers to ignore installing (or "all")
				-- ignore_install = { "javascript" },

				---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
				-- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

				highlight = {
					enable = true,

					-- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
					-- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
					-- the name of the parser)
					-- list of language that will be disabled
					-- disable = { "c", "rust" },
					-- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
					disable = function(lang, buf)
						local max_filesize = 500 * 1024 -- 100 KB
						local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
						if ok and stats and stats.size > max_filesize then
							return true
						end
					end,

					-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
					-- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
					-- Using this option may slow down your editor, and you may see some duplicate highlights.
					-- Instead of true it can also be a list of languages
					additional_vim_regex_highlighting = false,
				},
			},
			{
				"NMAC427/guess-indent.nvim",
				opts = {},
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
									arrow_open = "V",
									default = "",
									open = "V",
									empty = "",
									empty_open = "V",
									symlink = "",
									symlink_open = "V",
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
						-- Conform will run the first available formatter
						javascript = { "prettier", stop_after_first = true },
						typescript = { "prettier", stop_after_first = true },
						nim = { "nimpretty" },
					},
				},
			},
		},
	},
	-- Configure any other settings here. See the documentation for more details.
	-- colorscheme that will be used when installing plugins.
	-- install = { colorscheme = { "habamax" } },
	-- automatically check for plugin updates
	-- checker = { enabled = true },
})

-- FORMAT ON SAVE
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "*" },
	callback = function(args)
		local ft = vim.bo[args.buf].filetype
		if ft == "nim" or ft == "javascript" or ft == "typescript" then
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

vim.diagnostic.config({
	virtual_text = {
		enabled = true,
		-- current_line = true, -- Only show virtual text on the current line
	},
})
