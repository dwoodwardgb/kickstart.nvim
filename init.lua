vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require('packer').startup(function(use)
  use('wbthomason/packer.nvim')
  use('neovim/nvim-lspconfig')
use('nvim-treesitter/nvim-treesitter')
use('NMAC427/guess-indent.nvim')
use('echasnovski/mini.pick')
use('nvim-tree/nvim-tree.lua')
end)

-- vim.cmd [[PackerCompile]]
-- vim.cmd [[PackerInstall]]

-- vim.pack.add {
--   { src = 'https://github.com/neovim/nvim-lspconfig' },
--   {
--     src = 'https://github.com/nvim-treesitter/nvim-treesitter',
--     version = 'master', -- legacy version
--   },
--   { src = 'https://github.com/NMAC427/guess-indent.nvim' },
--   { src = 'https://github.com/echasnovski/mini.pick' },
--   { src = 'https://github.com/nvim-tree/nvim-tree.lua' },
-- }

vim.lsp.enable('gopls')
vim.lsp.enable('lua_ls')
vim.lsp.enable('nim_langserver')

require('guess-indent').setup {}
require('mini.pick').setup {}
require("nvim-tree").setup({
  view = {
    side = "right", -- Sets the NvimTree to open on the right side
  },
})

require 'nvim-treesitter.configs'.setup {
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
}

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
-- vim.cmd [[colorscheme modus]]

-- vim.keymap.set("n", "<leader>qq", ":enew<bar>bd #<CR>")
-- TODO: find a way to switch to the empty buffer, there should only be one

vim.keymap.set("n", "<leader>w", ":bd #<CR>")
vim.keymap.set('n', '<leader>p', ":Pick files<CR>")
vim.keymap.set('n', '<leader><tab>', ":Pick buffers<CR>")
vim.keymap.set('n', '<leader>b', ":NvimTreeToggle<CR>")

function setupFormatOnSave()
  -- Switch for controlling whether you want autoformatting.
  --  Use :KickstartFormatToggle to toggle autoformatting on or off
  local format_is_enabled = true
  vim.api.nvim_create_user_command('KickstartFormatToggle', function()
    format_is_enabled = not format_is_enabled
    print('Setting autoformatting to: ' .. tostring(format_is_enabled))
  end, {})

  -- Create an augroup that is used for managing our formatting autocmds.
  --      We need one augroup per client to make sure that multiple clients
  --      can attach to the same buffer without interfering with each other.
  local _augroups = {}
  local get_augroup = function(client)
    if not _augroups[client.id] then
      local group_name = 'kickstart-lsp-format-' .. client.name
      local id = vim.api.nvim_create_augroup(group_name, { clear = true })
      _augroups[client.id] = id
    end

    return _augroups[client.id]
  end

  -- Whenever an LSP attaches to a buffer, we will run this function.
  -- See `:help LspAttach` for more information about this autocmd event.
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('kickstart-lsp-attach-format', { clear = true }),
    callback = function(args)
      local client_id = args.data.client_id
      local client = vim.lsp.get_client_by_id(client_id)
      local bufnr = args.buf

      -- Only attach to clients that support document formatting
      if not client.server_capabilities.documentFormattingProvider then
        return
      end

      if client.name == 'tsserver' then
        -- TOOD: setup prettierd
        -- vim.api.nvim_command("autocmd BufWritePre <buffer> lua TsFormat()")
        return
      end

      -- Create an autocmd that will run *before* we save the buffer.
      --  Run the formatting command for the LSP that has just attached.
      vim.api.nvim_create_autocmd('BufWritePre', {
        group = get_augroup(client),
        buffer = bufnr,
        callback = function()
          if not format_is_enabled then
            return
          end

          vim.lsp.buf.format {
            async = false,
            filter = function(c)
              return c.id == client.id
            end,
          }
        end,
      })
    end,
  })
end

setupFormatOnSave()

vim.diagnostic.config({
  virtual_text = {
    enabled = true,
    -- current_line = true, -- Only show virtual text on the current line
  },
})
