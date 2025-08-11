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

local ensure_packer = function()
	local fn = vim.fn
	local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
	if fn.empty(fn.glob(install_path)) > 0 then
		fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
		vim.cmd([[packadd packer.nvim]])
		return true
	end
	return false
end

local packer_bootstrap = ensure_packer()

require("packer").startup(function(use)
	use("wbthomason/packer.nvim")
	if packer_bootstrap then
		require("packer").sync()
	end
	use({
		"neovim/nvim-lspconfig",
		config = function()
			vim.lsp.enable("gopls")
			vim.lsp.enable("lua_ls")
			vim.lsp.enable("nim_langserver")
			vim.lsp.enable("ts_ls")
		end,
	})
	use({
		"nvim-treesitter/nvim-treesitter",
		config = function()
			require("nvim-treesitter.configs").setup({
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
			})
		end,
	})
	use({
		"NMAC427/guess-indent.nvim",
		config = function()
			-- TODO: set language specific fallbacks/defaults
			require("guess-indent").setup()
		end,
	})
	use({
		"echasnovski/mini.pick",
		config = function()
			-- TODO: figure out why wont work in home directory
			require("mini.pick").setup()
		end,
	})
	use({
		"nvim-tree/nvim-tree.lua",
		config = function()
			-- TODO: turn off nerd font icons
			require("nvim-tree").setup({
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
			})
		end,
	})
	use({
		"stevearc/conform.nvim",
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					lua = { "stylua" },
					-- Conform will run the first available formatter
					javascript = { "prettier", stop_after_first = true },
					typescript = { "prettier", stop_after_first = true },
					nim = { "nimpretty" },
				},
			})
		end,
	})
	-- use({
	-- 	"echasnovski/mini.icons",
	-- 	config = function()
	-- 		-- TODO: figure out why wont work in home directory
	-- 		require("mini.icons").setup({
	-- 			style = "ascii",
	-- 		})
	-- 		MiniIcons.mock_nvim_web_devicons()
	-- 	end,
	-- })
end)

-- TODO: figure out why this works but the above doesn't
-- require("conform").setup({
-- 	formatters_by_ft = {
-- 		lua = { "stylua" },
-- 		-- Conform will run the first available formatter
-- 		javascript = { "prettier", stop_after_first = true },
-- 		typescript = { "prettier", stop_after_first = true },
-- 		nim = { "nimpretty" },
-- 	},
-- })

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
