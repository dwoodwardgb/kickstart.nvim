vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.keymap.set("n", "<leader>[", vim.cmd.tabprev)
vim.keymap.set("n", "<leader>]", vim.cmd.tabnext)
vim.opt.scrolloff = 5
vim.opt.relativenumber = true
vim.wo.fillchars = 'eob: '
vim.opt.completeopt = 'menuone,preview'
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.ruler = true
vim.opt.hlsearch = true
vim.opt.linebreak = true
vim.opt.breakat = '^I!@*+;,./?'
vim.opt.wrap = false

-- for neotree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require('packer').startup(function(use)
  use('wbthomason/packer.nvim')
  use({
    'neovim/nvim-lspconfig',
    config = function ()
      vim.lsp.enable('gopls')
      vim.lsp.enable('lua_ls')
      vim.lsp.enable('nim_langserver')
    end
  })
  use({
    'nvim-treesitter/nvim-treesitter',
    config = function ()
      require('nvim-treesitter.configs').setup({
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
          "html"
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
    end
  })
  use({
    'NMAC427/guess-indent.nvim',
    config = function ()
      -- TODO: set language specific fallbacks/defaults
      require('guess-indent').setup()
    end
  })
  use({
    'echasnovski/mini.pick',
    config = function ()
      require('mini.pick').setup()
    end
  })
  use({
    'nvim-tree/nvim-tree.lua',
    config = function ()
      require("nvim-tree").setup({
        view = {
          side = "right", -- Sets the NvimTree to open on the right side
        },
      })
    end
  })
  use({
    "stevearc/conform.nvim",
    config = function ()
      -- TODO: why didn't setting the table here work
    end,
  })
end)

-- TODO: figure out why this works but this doesnt
require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    -- Conform will run the first available formatter
    javascript = { "prettier", stop_after_first = true },
    typescript = { "prettier", stop_after_first = true },
    -- javascript = { "prettierd", "prettier", stop_after_first = true },
    nim = { "nimpretty" }
  },
})


vim.api.nvim_create_autocmd('FileType', {
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
  end 
})

vim.keymap.set("n", "<leader>w", ":bd #<CR>")
vim.keymap.set('n', '<leader>p', ":Pick files<CR>")
vim.keymap.set('n', '<leader><tab>', ":Pick buffers<CR>")
vim.keymap.set('n', '<leader>b', ":NvimTreeToggle<CR>")

vim.diagnostic.config({
  virtual_text = {
    enabled = true,
    -- current_line = true, -- Only show virtual text on the current line
  },
})
