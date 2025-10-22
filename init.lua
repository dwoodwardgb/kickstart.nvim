vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- space bracket for optional bnext

-- NOTE: See `:help vim.o`
--  TODO: consider remapping ; to : for easy commands
vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = 'a'
vim.o.showmode = true
vim.o.wrap = false
vim.opt.fillchars = { eob = ' ' }
vim.opt.completeopt = { 'menuone', 'noinsert', 'noselect', 'preview', 'popup' }
vim.o.breakat = '^I!@*+;,./?'
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'yes'
vim.o.timeoutlen = 350 -- Decrease mapped sequence wait time
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = '. ', trail = '·', nbsp = '␣' }
vim.o.inccommand = 'nosplit'
vim.o.cursorline = true -- Show which line your cursor is on
vim.o.scrolloff = 1
-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
vim.o.confirm = true

-- vim.o.colorcolumn = '+1'
-- vim.o.textwidth = 110

-- TODO: this is completely broken
vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.o.foldlevel = 5
-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

vim.g.have_nerd_font = false

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>') -- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set('n', '<leader>tw', '<cmd>set wrap!<CR>', { desc = '[T]oggle line [W]rap' })
vim.keymap.set('n', '<leader>w', '<cmd>bd<CR>', { desc = 'Close current buffer ([W]indow)' })
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
--  See `:help wincmd` for a list of all window commands
--  TODO: consider using Meta instead of control for ergonomics on real keyboard
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Quickfix and Loclist stuff
-- vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
function _G.ToggleQuickfix()
  local qf_open = false
  for _, win_info in ipairs(vim.fn.getwininfo()) do
    if win_info.quickfix == 1 then
      qf_open = true
      break
    end
  end

  if qf_open then
    vim.cmd 'cclose'
  else
    vim.cmd 'copen'
  end
end
vim.keymap.set('n', '<leader>q', ':lua ToggleQuickfix()<CR>', { noremap = true, silent = true, desc = 'Toggle [Q]uickfix list' })
vim.keymap.set('n', '<leader>l', '<cmd>lopen<CR>', { desc = 'Open diagnostic [L]ocation list' })
-- NOTE: here's how to do find and replace w/quickfixlist:
-- :vimgrep /old_function/j **/*.py
-- :cfdo %s/old_function/new_function/g | update

-- TODO: undo tree history
-- TODO: resume last place in file
-- TODO: yank, paste, delete without poluting the system clipboard
-- TODO: limit jumplist to file directory and or support jumplist tree or advanced stuff

-- Netrw
-- TODO: toggle it to show hide, possibly as a sidebar
vim.g.netrw_liststyle = 3

-- ctrl+` for term toggle
vim.keymap.set('n', '<C-`>', function()
  local bufnr = -1
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(b) and vim.bo[b].buftype == 'terminal' then
      bufnr = b
      break
    end
  end

  if bufnr ~= -1 then
    vim.api.nvim_set_current_buf(bufnr)
  else
    vim.cmd 'terminal'
  end
end, { noremap = true, silent = true })

-- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
-- vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
-- vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
-- vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
-- vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Return to last edit position when opening files
vim.api.nvim_create_autocmd('BufReadPost', {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Force .pp to be treated as json files, not Pascal
-- NOTE: used AI, could be wrong
-- TODO: decide if BufEnter is the best trigger
vim.api.nvim_create_autocmd('BufEnter', {
  pattern = '*.pp',
  callback = function()
    -- Only set if it's not already set, to avoid infinite loops or unnecessary work
    if vim.bo.filetype ~= 'json' then
      vim.bo.filetype = 'json'
      -- print("Debug: .pp set to json (BufEnter fallback)")
    end
  end,
  desc = 'Force .pp files to json (BufEnter fallback)',
})

-- Default indent settings, will be overrident by guess-indent and this autocommand
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.api.nvim_create_autocmd('BufEnter', {
  pattern = '*',
  callback = function()
    -- TODO: set max column/ruler and configure q to wrap comments correctly accordingly
    if vim.bo.filetype == 'go' then
      vim.o.tabstop = 4
    else
    end
  end,
  desc = 'Set language specific settings',
})

-- Autoformat
vim.b.disable_autoformat = false
vim.g.disable_autoformat = false
vim.api.nvim_create_user_command('NoFormatOnSave', function(args)
  if args.bang then
    -- FormatDisable! will disable formatting just for this buffer
    vim.b.disable_autoformat = true
  else
    vim.g.disable_autoformat = true
  end
end, {
  desc = 'Disable autoformat-on-save',
  bang = true,
})
vim.api.nvim_create_user_command('FormatOnSave', function()
  vim.b.disable_autoformat = false
  vim.g.disable_autoformat = false
end, {
  desc = 'Re-enable autoformat-on-save',
})
vim.api.nvim_create_user_command('FormatOnSaveInfo', function()
  print('global format on save disabled: ' .. tostring(vim.g.disable_autoformat))
  print('buffer format on save disabled: ' .. tostring(vim.b.disable_autoformat))
end, {
  desc = 'Show state of format on save',
})
vim.api.nvim_create_user_command('ToggleFormatOnSave', function(args)
  if args.bang then
    -- FormatDisable! will disable formatting just for this buffer
    vim.b.disable_autoformat = not vim.b.disable_autoformat
  else
    vim.g.disable_autoformat = not vim.g.disable_autoformat
  end
end, {
  desc = 'Toggle autoformat-on-save',
  bang = true,
})
vim.keymap.set('n', '<leader>tf', '<cmd>ToggleFormatOnSave<CR>', { desc = '[T]oggle format on save' })

vim.keymap.set('n', '<M-]>', '<cmd>bnext<CR>', { desc = 'Next buffer ]', silent = true })
vim.keymap.set('n', '<leader>]', '<cmd>bnext<CR>', { desc = 'Next buffer ]', silent = true })
vim.keymap.set('n', '<M-[>', '<cmd>bprev<CR>', { desc = 'Prev buffer [', silent = true })
vim.keymap.set('n', '<leader>[', '<cmd>bprev<CR>', { desc = 'Prev buffer [', silent = true })

-- TODO: makeprg set to npm run check or wahtever based on project

-- TODO: handle editor closing unexpectedly, maybe globally check for buffer on quit

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end

-- Color stuff
local function print_colored_text(text, hex_color)
  local hl_group_name = 'CustomColor_' .. hex_color:gsub('#', '')
  vim.api.nvim_set_hl(0, hl_group_name, { fg = hex_color })
  vim.api.nvim_echo({ { text, hl_group_name } }, true, {})
end

-- For debugging
vim.api.nvim_create_user_command('DebugTermcolors', function(args)
  print_colored_text('SAMPLE', vim.g.terminal_color_1)
  print_colored_text('SAMPLE', vim.g.terminal_color_2)
  print_colored_text('SAMPLE', vim.g.terminal_color_3)
  print_colored_text('SAMPLE', vim.g.terminal_color_4)
  print_colored_text('SAMPLE', vim.g.terminal_color_5)
  print_colored_text('SAMPLE', vim.g.terminal_color_6)
  print_colored_text('SAMPLE', vim.g.terminal_color_7)
  print_colored_text('SAMPLE', vim.g.terminal_color_8)
  print_colored_text('SAMPLE', vim.g.terminal_color_9)
  print_colored_text('SAMPLE', vim.g.terminal_color_10)
  print_colored_text('SAMPLE', vim.g.terminal_color_11)
  print_colored_text('SAMPLE', vim.g.terminal_color_12)
  print_colored_text('SAMPLE', vim.g.terminal_color_13)
  print_colored_text('SAMPLE', vim.g.terminal_color_14)
  print_colored_text('SAMPLE', vim.g.terminal_color_15)
end, {
  desc = '',
})
vim.api.nvim_create_autocmd('ColorScheme', {
  pattern = '*',
  callback = function()
    if vim.o.background == 'light' then
      vim.g.terminal_color_8 = '#333333'
    else
      vim.g.terminal_color_8 = '#aaaaaa'
    end
  end,
})

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)
require('lazy').setup({
  install = { colorscheme = { 'default' } },
  -- Auto theme detection plugin
  {
    -- NOTE: you can use dark-notify if you're only tragetting MacOS. Using this instead because this config is used on Linux sometimes
    'f-person/auto-dark-mode.nvim',
    config = function()
      local auto_dark_mode = require 'auto-dark-mode'
      auto_dark_mode.setup {
        update_interval = 4000, -- Check for theme changes every 4 seconds
        set_dark_mode = function()
          vim.cmd.colorscheme 'kanagawa-dragon'
        end,
        set_light_mode = function()
          vim.cmd.colorscheme 'default'
          vim.cmd.colorscheme 'modus'
        end,
      }
    end,
  },
  -- lights themes
  { 'ronisbr/nano-theme.nvim' },
  { 'kepano/flexoki-neovim' },
  { 'rayes0/blossom.vim' },
  { 'p00f/alabaster.nvim' },
  { 'josebalius/vim-light-chromeclipse' },
  {
    'miikanissi/modus-themes.nvim',
    config = function()
      require('modus-themes').setup {
        styles = {
          comments = { italic = false },
          keywords = { italic = false },
          functions = {},
          variables = {},
        },
      }
    end,
  },
  {
    'iibe/gruvbox-high-contrast',
    config = function()
      vim.g.gruvbox_bold = 0
      vim.g.gruvbox_italic = 0
      vim.g.gruvbox_transparent_bg = 1
    end,
  },
  {
    'racakenon/mytilus',
    config = function()
      require('mytilus.configs').setup {
        options = {
          sideBarDim = false, --if false then sidebar bg is same normal
          statusBarRevers = true, --if false, statusBarRevers bg is d2_black,
          NCWindowDim = true, --if false, not current window bg is same normal
          str = { bold = false },
          func = { bold = false, italic = false },
        },
      }
    end,
  },
  { 'vim-scripts/vylight' },
  { 'scheakur/vim-scheakur' },
  -- dark themes
  { 'frenzyexists/aquarium-vim' },
  { 'xiantang/darcula-dark.nvim' },
  {
    'rebelot/kanagawa.nvim',
    config = function()
      require('kanagawa').setup {
        commentStyle = { italic = false },
        functionStyle = { italic = false },
        keywordStyle = { italic = false },
        statementStyle = { bold = false },
      }
    end,
  },
  {
    'folke/tokyonight.nvim',
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require('tokyonight').setup {
        styles = {
          comments = { italic = false }, -- Disable italics in comments
          functionStyle = { italic = false },
          keywordStyle = { italic = false },
          statementStyle = { bold = false },
        },
      }
    end,
  },
  { 'thepogsupreme/mountain.nvim' },
  { 'pauchiner/pastelnight.nvim' },
  { 'NMAC427/guess-indent.nvim' },
  { -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },
  {
    'nvim-tree/nvim-tree.lua',
    config = function()
      require('nvim-tree').setup {
        on_attach = function(buf_number)
          local api = require 'nvim-tree.api'
          api.config.mappings.default_on_attach(buf_number)
        end,
        hijack_cursor = false,
        auto_reload_on_write = true,
        disable_netrw = false,
        hijack_netrw = true,
        hijack_unnamed_buffer_when_opening = true,
        root_dirs = {},
        prefer_startup_root = true,
        sync_root_with_cwd = false,
        reload_on_bufenter = false,
        respect_buf_cwd = false,
        select_prompts = false,
        sort = {
          sorter = 'name',
          folders_first = true,
          files_first = false,
        },
        view = {
          centralize_selection = false,
          cursorline = true,
          cursorlineopt = 'both',
          debounce_delay = 15,
          side = 'right',
          preserve_window_proportions = true,
          number = false,
          relativenumber = false,
          signcolumn = 'yes',
          width = 50,
          float = {
            enable = false,
            quit_on_focus_loss = true,
            open_win_config = {
              relative = 'editor',
              border = 'rounded',
              width = 30,
              height = 30,
              row = 1,
              col = 1,
            },
          },
        },
        renderer = {
          add_trailing = false,
          group_empty = false,
          full_name = false,
          root_folder_label = ':~:s?$?/..?',
          indent_width = 2,
          special_files = { 'Cargo.toml', 'Makefile', 'makefile', 'README.md', 'readme.md' },
          hidden_display = 'none',
          symlink_destination = true,
          decorators = { 'Git', 'Open', 'Hidden', 'Modified', 'Bookmark', 'Diagnostics', 'Copied', 'Cut' },
          highlight_git = 'none',
          highlight_diagnostics = 'none',
          highlight_opened_files = 'none',
          highlight_modified = 'none',
          highlight_hidden = 'none',
          highlight_bookmarks = 'none',
          highlight_clipboard = 'name',
          indent_markers = {
            enable = true,
            inline_arrows = true,
            icons = {
              corner = '└',
              edge = '│',
              item = '│',
              bottom = '─',
              none = ' ',
            },
          },
          icons = {
            web_devicons = {
              file = {
                enable = true,
                color = true,
              },
              folder = {
                enable = false,
                color = true,
              },
            },
            git_placement = 'before',
            modified_placement = 'after',
            hidden_placement = 'after',
            diagnostics_placement = 'signcolumn',
            bookmarks_placement = 'signcolumn',
            padding = {
              icon = ' ',
              folder_arrow = ' ',
            },
            symlink_arrow = ' ➛ ',
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = true,
              modified = true,
              hidden = false,
              diagnostics = true,
              bookmarks = true,
            },
            glyphs = {
              default = '',
              symlink = '',
              bookmark = '󰆤',
              modified = '●',
              hidden = '󰜌',
              folder = {
                arrow_closed = '',
                arrow_open = '',
                default = '',
                open = '',
                empty = '',
                empty_open = '',
                symlink = '',
                symlink_open = '',
              },
              git = {
                unstaged = '✗',
                staged = '✓',
                unmerged = '',
                renamed = '➜',
                untracked = '★',
                deleted = '',
                ignored = '◌',
              },
            },
          },
        },
        hijack_directories = {
          enable = true,
          auto_open = true,
        },
        update_focused_file = {
          enable = true,
          update_root = {
            enable = false,
            ignore_list = {},
          },
          exclude = false,
        },
        system_open = {
          cmd = '',
          args = {},
        },
        git = {
          enable = true,
          show_on_dirs = true,
          show_on_open_dirs = true,
          disable_for_dirs = {},
          timeout = 400,
          cygwin_support = false,
        },
        diagnostics = {
          enable = false,
          show_on_dirs = false,
          show_on_open_dirs = true,
          debounce_delay = 500,
          severity = {
            min = vim.diagnostic.severity.HINT,
            max = vim.diagnostic.severity.ERROR,
          },
          icons = {
            hint = '',
            info = '',
            warning = '',
            error = '',
          },
          diagnostic_opts = false,
        },
        modified = {
          enable = false,
          show_on_dirs = true,
          show_on_open_dirs = true,
        },
        filters = {
          enable = false,
          git_ignored = true,
          dotfiles = false,
          git_clean = false,
          no_buffer = false,
          no_bookmark = false,
          custom = {},
          exclude = {},
        },
        live_filter = {
          prefix = '[FILTER]: ',
          always_show_folders = true,
        },
        filesystem_watchers = {
          enable = true,
          debounce_delay = 50,
          ignore_dirs = {
            '/.ccls-cache',
            '/build',
            '/node_modules',
            '/target',
          },
        },
        actions = {
          use_system_clipboard = true,
          change_dir = {
            enable = true,
            global = false,
            restrict_above_cwd = false,
          },
          expand_all = {
            max_folder_discovery = 300,
            exclude = {},
          },
          file_popup = {
            open_win_config = {
              col = 1,
              row = 1,
              relative = 'cursor',
              border = 'shadow',
              style = 'minimal',
            },
          },
          open_file = {
            quit_on_open = false,
            eject = true,
            resize_window = true,
            relative_path = true,
            window_picker = {
              enable = true,
              picker = 'default',
              chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890',
              exclude = {
                filetype = { 'notify', 'packer', 'qf', 'diff', 'fugitive', 'fugitiveblame' },
                buftype = { 'nofile', 'terminal', 'help' },
              },
            },
          },
          remove_file = {
            close_window = true,
          },
        },
        trash = {
          cmd = 'gio trash',
        },
        tab = {
          sync = {
            open = false,
            close = false,
            ignore = {},
          },
        },
        notify = {
          threshold = vim.log.levels.INFO,
          absolute_path = true,
        },
        help = {
          sort_by = 'key',
        },
        ui = {
          confirm = {
            remove = true,
            trash = true,
            default_yes = false,
          },
        },
        experimental = {},
        log = {
          enable = false,
          truncate = false,
          types = {
            all = false,
            config = false,
            copy_paste = false,
            dev = false,
            diagnostics = false,
            git = false,
            profile = false,
            watcher = false,
          },
        },
      }
    end,
  },

  -- NOTE: Plugins can also be configured to run Lua code when they are loaded.
  -- This is often very useful to both group configuration, as well as handle
  -- lazy loading plugins that don't need to be loaded immediately at startup.
  -- For example, in the following configuration, we use:
  --  event = 'VimEnter'
  -- which loads which-key before all the UI elements are loaded. Events can be
  -- normal autocommands events (`:help autocmd-events`).
  -- Then, because we use the `opts` key (recommended), the configuration runs
  -- after the plugin has been loaded as `require(MODULE).setup(opts)`.
  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VimEnter', -- Sets the loading event to 'VimEnter'
    opts = {
      -- delay between pressing a key and opening which-key (milliseconds)
      -- this setting is independent of vim.o.timeoutlen
      delay = 0,
      icons = {
        -- set icon mappings to true if you have a Nerd Font
        mappings = vim.g.have_nerd_font,
        -- If you are using a Nerd Font: set icons.keys to an empty table which will use the
        -- default which-key.nvim defined Nerd Font icons, otherwise define a string table
        keys = vim.g.have_nerd_font and {} or {
          Up = '<Up> ',
          Down = '<Down> ',
          Left = '<Left> ',
          Right = '<Right> ',
          C = '<C-…> ',
          M = '<M-…> ',
          D = '<D-…> ',
          S = '<S-…> ',
          CR = '<CR> ',
          Esc = '<Esc> ',
          ScrollWheelDown = '<ScrollWheelDown> ',
          ScrollWheelUp = '<ScrollWheelUp> ',
          NL = '<NL> ',
          BS = '<BS> ',
          Space = '<Space> ',
          Tab = '<Tab> ',
          F1 = '<F1>',
          F2 = '<F2>',
          F3 = '<F3>',
          F4 = '<F4>',
          F5 = '<F5>',
          F6 = '<F6>',
          F7 = '<F7>',
          F8 = '<F8>',
          F9 = '<F9>',
          F10 = '<F10>',
          F11 = '<F11>',
          F12 = '<F12>',
        },
      },

      -- Document existing key chains
      spec = {
        { '<leader>s', group = '[S]earch' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      },

      triggers = {
        { '<leader>', mode = { 'n', 'v' } },
        { 'g', mode = { 'n', 'v' } },
        { 'z', mode = { 'n', 'v' } },
        { 'h', mode = { 'n', 'v' } },
        { 't', mode = { 'n' } },
        -- TODO: get trigger for 'v' in normal mode working again
        -- NOTE: from nvchad:
        -- keys = { "<leader>", "<c-w>", '"', "'", "`", "c", "v", "g" },
      },
    },
  },
  {
    'nvim-mini/mini.tabline',
    config = function()
      require('mini.tabline').setup {
        show_icons = false,
        -- Function which formats the tab label
        -- By default surrounds with space and possibly prepends with icon
        format = nil,
        -- Where to show tabpage section in case of multiple vim tabpages.
        -- One of 'left', 'right', 'none'.
        tabpage_section = 'left',
      }
    end,
  },
  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { -- If encountering errors, see telescope-fzf-native README for installation instructions
        'nvim-telescope/telescope-fzf-native.nvim',

        -- `build` is used to run some command when the plugin is installed/updated.
        -- This is only run then, not every time Neovim starts up.
        build = 'make',

        -- `cond` is a condition used to determine whether this plugin should be
        -- installed and loaded.
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },

      -- Useful for getting pretty icons, but requires a Nerd Font.
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      -- Telescope is a fuzzy finder that comes with a lot of different things that
      -- it can fuzzy find! It's more than just a "file finder", it can search
      -- many different aspects of Neovim, your workspace, LSP, and more!
      --
      -- The easiest way to use Telescope, is to start by doing something like:
      --  :Telescope help_tags
      --
      -- After running this command, a window will open up and you're able to
      -- type in the prompt window. You'll see a list of `help_tags` options and
      -- a corresponding preview of the help.
      --
      -- Two important keymaps to use while in Telescope are:
      --  - Insert mode: <c-/>
      --  - Normal mode: ?
      --
      -- This opens a window that shows you all of the keymaps for the current
      -- Telescope picker. This is really useful to discover what Telescope can
      -- do as well as how to actually do it!

      -- [[ Configure Telescope ]]
      -- See `:help telescope` and `:help telescope.setup()`
      require('telescope').setup {
        -- You can put your default mappings / updates / etc. in here
        --  All the info you're looking for is in `:help telescope.setup()`
        --
        -- defaults = {
        --   mappings = {
        --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
        --   },
        -- },
        -- pickers = {}
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      -- Enable Telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      -- See `:help telescope.builtin`
      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>p', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>f', builtin.live_grep, { desc = '[F]ind in files' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })
      vim.keymap.set('n', '<leader>kt', builtin.colorscheme, { desc = 'Search themes' })

      -- Slightly advanced example of overriding default behavior and theme
      vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      -- It's also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = '[S]earch [/] in Open Files' })

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
    end,
  },
  -- LSP Plugins
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    -- Main LSP Configuration
    -- See `:help lsp-vs-treesitter`
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Useful status updates for LSP.
      { 'j-hui/fidget.nvim', opts = {} },
      -- Allows extra capabilities provided by blink.cmp
      'saghen/blink.cmp',
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          -- map('gn', vim.lsp.buf.rename, '[R]e[n]ame')

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          -- map('ga', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })

          -- Find references for the word under your cursor.
          -- map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          -- map('gr', vim.lsp.buf.references, '[G]oto [R]eferences', { 'n' })

          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          -- map('gi', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          -- map('gi', vim.lsp.buf.implementation, '[G]oto [I]mplementation', { 'n' })

          vim.keymap.set('n', 'grr', require('telescope.builtin').lsp_references, { desc = '[G]oto [R]eferences' })
          vim.keymap.set('n', 'gri', require('telescope.builtin').lsp_implementations, { desc = '[G]oto [I]mplementation' })
          vim.keymap.set('n', 'grd', require('telescope.builtin').lsp_definitions, { desc = '[G]oto [D]efinition' })
          vim.keymap.set('n', 'grD', vim.lsp.buf.declaration, { desc = '[G]oto [D]eclaration' })
          vim.keymap.set('n', 'gO', require('telescope.builtin').lsp_document_symbols, { desc = 'Open Document Symbols' })
          vim.keymap.set('n', 'gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, { desc = 'Open Workspace Symbols' })
          vim.keymap.set('n', 'grt', require('telescope.builtin').lsp_type_definitions, { desc = '[G]oto [T]ype Definition' })

          -- Jump to the definition of the word under your cursor.
          --  This is where a variable was first declared, or where a function is defined, etc.
          --  To jump back, press <C-t>.
          -- map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          vim.keymap.set('n', '<Plug>OriginalGd', 'gd', { silent = true })
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = '[G]oto [D]efinition' })
          -- TODO: use OriginalGd as a fallback if not supported by LS
          -- map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          vim.keymap.set('n', 'gD', '<Plug>OriginalGd', { desc = 'Built-in Go to Definition' })

          -- Fuzzy find all the symbols in your current document.
          --  Symbols are things like variables, functions, types, etc.
          -- map('gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')

          -- Fuzzy find all the symbols in your current workspace.
          --  Similar to document symbols, except searches over your entire project.
          -- map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')

          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          -- map('grt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')

          vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Hover' })
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            callback = vim.diagnostic.open_float,
          })

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            -- vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            --   buffer = event.buf,
            --   group = highlight_augroup,
            --   callback = vim.lsp.buf.clear_references,
            -- })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          -- The following code creates a keymap to toggle inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            vim.keymap.set('n', '<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, { desc = '[T]oggle Inlay [H]ints' })
          end

          if client and client.name == 'ts_ls' or client.name == 'vtsls' then
            vim.o.makeprg = './node_modules/.bin/tsc --pretty false --noEmit'
            vim.opt.errorformat = '%f(%l\\,%c): %t%*[^:]:%m'
          end
        end,
      })

      -- Diagnostic Config
      -- See :help vim.diagnostic.Opts
      vim.diagnostic.config {
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        },
        virtual_text = {
          source = 'if_many',
          spacing = 2,
          format = function(diagnostic)
            local diagnostic_message = {
              [vim.diagnostic.severity.ERROR] = diagnostic.message,
              [vim.diagnostic.severity.WARN] = diagnostic.message,
              [vim.diagnostic.severity.INFO] = diagnostic.message,
              [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
          end,
        },
      }
      vim.lsp.config('lua_ls', {
        settings = {
          Lua = {
            completion = {
              callSnippet = 'Replace',
            },
            -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
            -- diagnostics = { disable = { 'missing-fields' } },
          },
        },
      })
      vim.lsp.config('jdtls', {
        settings = {
          java = {},
        },
      })
      local servers_enabled = {
        'lua_ls',
        'vtsls',
        'gopls',
        'jdtls',
      }
      for _, ls in ipairs(servers_enabled) do
        vim.lsp.enable(ls)
      end
    end,
  },
  { -- Autocompletion
    'saghen/blink.cmp',
    event = 'VimEnter',
    version = '1.*',
    dependencies = {
      -- Snippet Engine
      {
        'L3MON4D3/LuaSnip',
        version = '2.*',
        build = (function()
          -- Build Step is needed for regex support in snippets.
          -- This step is not supported in many windows environments.
          -- Remove the below condition to re-enable on windows.
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          -- `friendly-snippets` contains a variety of premade snippets.
          --    See the README about individual language/framework/plugin snippets:
          --    https://github.com/rafamadriz/friendly-snippets
          -- {
          --   'rafamadriz/friendly-snippets',
          --   config = function()
          --     require('luasnip.loaders.from_vscode').lazy_load()
          --   end,
          -- },
        },
        opts = {},
      },
    },
    --- @module 'blink.cmp'
    --- @type blink.cmp.Config
    opts = {
      keymap = {
        -- enter to select, see https://cmp.saghen.dev/configuration/keymap.html#presets for details
        preset = 'enter',
        ['<M-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
        -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
        --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
      },
      appearance = {
        -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        -- NOTE: commented out because I'm not using icons
        -- TODO: can I recreate this with unicode stuff?
        -- nerd_font_variant = 'mono',
      },
      completion = {
        -- By default, you may press `<c-space>` to show the documentation.
        -- Optionally, set `auto_show = true` to show the documentation after a delay.
        documentation = { auto_show = false, auto_show_delay_ms = 500 },
        list = {
          -- kind of like select,noinsert
          selection = { preselect = true, auto_insert = false },
        },
        accept = {
          auto_brackets = {
            enabled = false,
            kind_resolution = { enabled = false },
            semantic_token_resolution = { enabled = true },
          },
        },
      },
      cmdline = {
        enabled = false,
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'lazydev' },
        providers = {
          lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
        },
      },
      snippets = { preset = 'luasnip' },

      -- Blink.cmp includes an optional, recommended rust fuzzy matcher,
      -- which automatically downloads a prebuilt binary when enabled.
      --
      -- By default, we use the Lua implementation instead, but you may enable
      -- the rust implementation via `'prefer_rust_with_warning'`
      --
      -- See :h blink-cmp-config-fuzzy for more information
      fuzzy = { implementation = 'prefer_rust' },

      -- Shows a signature help window while you type arguments for a function
      signature = { enabled = true },
      term = {
        enabled = false,
      },
    },
  },

  { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>=',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- Disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style. You can add additional
        -- languages here or re-enable it for the disabled ones.
        local disable_filetypes = { c = true, cpp = true }
        if disable_filetypes[vim.bo[bufnr].filetype] or vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return nil
        else
          return {
            timeout_ms = 800,
            lsp_format = 'fallback',
          }
        end
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        javascript = { 'prettier' },
        typescript = { 'prettier' },
        typescriptreact = { 'prettier' },
        json = { 'prettier' },
        css = { 'prettier' },
        scss = { 'prettier' },
        nim = { 'nimpretty' },
      },
    },
  },

  -- Highlight todo, notes, etc in comments
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs', -- Sets main module to use for opts
    -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
    opts = {
      ensure_installed = {
        'bash',
        'c',
        'diff',
        'html',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'query',
        'vim',
        'vimdoc',
        'nim',
        'json',
        'javascript',
        'typescript',
        'java',
      },
      -- Autoinstall languages that are not installed
      auto_install = true,
      highlight = {
        enable = true,
        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --  If you are experiencing weird indenting issues, add the language to
        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
    },
    -- There are additional nvim-treesitter modules that you can use to interact
    -- with nvim-treesitter. You should go explore a few and see what interests you:
    --
    --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
    --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
    --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
  },

  -- The following comments only work if you have downloaded the kickstart repo, not just copy pasted the
  -- init.lua. If you want these files, they are in the repository, so you can just download them and
  -- place them in the correct locations.

  -- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for Kickstart
  --
  --  Here are some example plugins that I've included in the Kickstart repository.
  --  Uncomment any of the lines below to enable them (you will need to restart nvim).
  --
  -- require 'kickstart.plugins.debug',
  -- require 'kickstart.plugins.indent_line',
  -- require 'kickstart.plugins.lint',
  -- require 'kickstart.plugins.autopairs',
  require 'kickstart.plugins.gitsigns', -- adds gitsigns recommend keymaps

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    This is the easiest way to modularize your config.
  --
  --  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  -- { import = 'custom.plugins' },
  --
  -- For additional information with loading, sourcing and examples see `:help lazy.nvim-🔌-plugin-spec`
  -- Or use telescope!
  -- In normal mode type `<space>sh` then write `lazy.nvim-plugin`
  -- you can continue same window with `<space>sr` which resumes last telescope search
}, {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})
