-- vim.g.loaded_netrw = 1
-- vim.g.loaded_netrwPlugin = 1

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
          -- vim.cmd.colorscheme 'lucius'
          vim.cmd.colorscheme 'modus'
        end,
      }
    end,
  },
  -- lights themes
  { 'chiendo97/intellij.vim' },
  { 'razcoen/fleet.nvim' },
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
  { 'wtfox/jellybeans.nvim' },
  { 'makestatic/oblique.nvim' },
  { 'w0ng/vim-hybrid' },
  { 'jonathanfilip/vim-lucius' },
  { 'habamax/vim-polar' },
  'ramojus/mellifluous.nvim',
  'tiesen243/vercel.nvim',
  'vim-scripts/silent.vim',
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
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      -- "nvim-tree/nvim-web-devicons", -- optional, but recommended
    },
    lazy = false, -- neo-tree will lazily load itself
    config = function()
      vim.keymap.set('n', '<leader>e', '<Cmd>Neotree<CR>')
      require('neo-tree').setup {
        close_if_last_window = false, -- Close Neo-tree if it is the last window left in the tab
        popup_border_style = '', -- or "" to use 'winborder' on Neovim v0.11+
        clipboard = {
          sync = 'none', -- or "global"/"universal" to share a clipboard for each/all Neovim instance(s), respectively
        },
        enable_git_status = true,
        enable_diagnostics = true,
        open_files_do_not_replace_types = { 'terminal', 'trouble', 'qf' }, -- when opening files, do not use windows containing these filetypes or buftypes
        open_files_using_relative_paths = false,
        sort_case_insensitive = false, -- used when sorting files and directories in the tree
        sort_function = nil, -- use a custom function for sorting files and directories in the tree
        -- sort_function = function (a,b)
        --       if a.type == b.type then
        --           return a.path > b.path
        --       else
        --           return a.type > b.type
        --       end
        --   end , -- this sorts files and directories descendantly
        default_component_configs = {
          container = {
            enable_character_fade = true,
          },
          indent = {
            indent_size = 2,
            padding = 1, -- extra padding on left hand side
            -- indent guides
            with_markers = true,
            indent_marker = '│',
            last_indent_marker = '└',
            highlight = 'NeoTreeIndentMarker',
            -- expander config, needed for nesting files
            with_expanders = nil, -- if nil and file nesting is enabled, will enable expanders
            expander_collapsed = '',
            expander_expanded = '',
            expander_highlight = 'NeoTreeExpander',
          },
          icon = {
            folder_closed = '',
            folder_open = '',
            folder_empty = '󰜌',
            provider = function(icon, node, state) -- default icon provider utilizes nvim-web-devicons if available
              if node.type == 'file' or node.type == 'terminal' then
                local success, web_devicons = pcall(require, 'nvim-web-devicons')
                local name = node.type == 'terminal' and 'terminal' or node.name
                if success then
                  local devicon, hl = web_devicons.get_icon(name)
                  icon.text = devicon or icon.text
                  icon.highlight = hl or icon.highlight
                end
              end
            end,
            -- The next two settings are only a fallback, if you use nvim-web-devicons and configure default icons there
            -- then these will never be used.
            default = '*',
            highlight = 'NeoTreeFileIcon',
            use_filtered_colors = true, -- Whether to use a different highlight when the file is filtered (hidden, dotfile, etc.).
          },
          modified = {
            symbol = '[+]',
            highlight = 'NeoTreeModified',
          },
          name = {
            trailing_slash = false,
            use_filtered_colors = true, -- Whether to use a different highlight when the file is filtered (hidden, dotfile, etc.).
            use_git_status_colors = true,
            highlight = 'NeoTreeFileName',
          },
          git_status = {
            symbols = {
              -- Change type
              added = '', -- or "✚"
              modified = '', -- or ""
              deleted = '✖', -- this can only be used in the git_status source
              renamed = '󰁕', -- this can only be used in the git_status source
              -- Status type
              untracked = '',
              ignored = '',
              unstaged = '󰄱',
              staged = '',
              conflict = '',
            },
          },
          -- If you don't want to use these columns, you can set `enabled = false` for each of them individually
          file_size = {
            enabled = true,
            width = 12, -- width of the column
            required_width = 64, -- min width of window required to show this column
          },
          type = {
            enabled = true,
            width = 10, -- width of the column
            required_width = 122, -- min width of window required to show this column
          },
          last_modified = {
            enabled = true,
            width = 20, -- width of the column
            required_width = 88, -- min width of window required to show this column
          },
          created = {
            enabled = true,
            width = 20, -- width of the column
            required_width = 110, -- min width of window required to show this column
          },
          symlink_target = {
            enabled = false,
          },
        },
        -- A list of functions, each representing a global custom command
        -- that will be available in all sources (if not overridden in `opts[source_name].commands`)
        -- see `:h neo-tree-custom-commands-global`
        commands = {},
        window = {
          position = 'right',
          width = 40,
          mapping_options = {
            noremap = true,
            nowait = true,
          },
          mappings = {
            ['<space>'] = {
              'toggle_node',
              nowait = false, -- disable `nowait` if you have existing combos starting with this char that you want to use
            },
            ['<2-LeftMouse>'] = 'open',
            ['<cr>'] = 'open',
            ['<esc>'] = 'cancel', -- close preview or floating neo-tree window
            ['P'] = {
              'toggle_preview',
              config = {
                use_float = true,
                use_snacks_image = true,
                use_image_nvim = true,
              },
            },
            -- Read `# Preview Mode` for more information
            ['l'] = 'focus_preview',
            ['S'] = 'open_split',
            ['s'] = 'open_vsplit',
            -- ["S"] = "split_with_window_picker",
            -- ["s"] = "vsplit_with_window_picker",
            ['t'] = 'open_tabnew',
            -- ["<cr>"] = "open_drop",
            -- ["t"] = "open_tab_drop",
            ['w'] = 'open_with_window_picker',
            --["P"] = "toggle_preview", -- enter preview mode, which shows the current node without focusing
            ['C'] = 'close_node',
            -- ['C'] = 'close_all_subnodes',
            ['z'] = 'close_all_nodes',
            --["Z"] = "expand_all_nodes",
            --["Z"] = "expand_all_subnodes",
            ['a'] = {
              'add',
              -- this command supports BASH style brace expansion ("x{a,b,c}" -> xa,xb,xc). see `:h neo-tree-file-actions` for details
              -- some commands may take optional config options, see `:h neo-tree-mappings` for details
              config = {
                show_path = 'none', -- "none", "relative", "absolute"
              },
            },
            ['A'] = 'add_directory', -- also accepts the optional config.show_path option like "add". this also supports BASH style brace expansion.
            ['d'] = 'delete',
            ['r'] = 'rename',
            ['b'] = 'rename_basename',
            ['y'] = 'copy_to_clipboard',
            ['x'] = 'cut_to_clipboard',
            ['p'] = 'paste_from_clipboard',
            ['<C-r>'] = 'clear_clipboard',
            ['c'] = 'copy', -- takes text input for destination, also accepts the optional config.show_path option like "add":
            -- ["c"] = {
            --  "copy",
            --  config = {
            --    show_path = "none" -- "none", "relative", "absolute"
            --  }
            --}
            ['m'] = 'move', -- takes text input for destination, also accepts the optional config.show_path option like "add".
            ['q'] = 'close_window',
            ['R'] = 'refresh',
            ['?'] = 'show_help',
            ['<'] = 'prev_source',
            ['>'] = 'next_source',
            ['i'] = 'show_file_details',
            -- ["i"] = {
            --   "show_file_details",
            --   -- format strings of the timestamps shown for date created and last modified (see `:h os.date()`)
            --   -- both options accept a string or a function that takes in the date in seconds and returns a string to display
            --   -- config = {
            --   --   created_format = "%Y-%m-%d %I:%M %p",
            --   --   modified_format = "relative", -- equivalent to the line below
            --   --   modified_format = function(seconds) return require('neo-tree.utils').relative_date(seconds) end
            --   -- }
            -- },
          },
        },
        nesting_rules = {},
        filesystem = {
          filtered_items = {
            visible = true, -- when true, they will just be displayed differently than normal items
            hide_dotfiles = true,
            hide_gitignored = true,
            hide_ignored = true, -- hide files that are ignored by other gitignore-like files
            -- other gitignore-like files, in descending order of precedence.
            ignore_files = {
              '.neotreeignore',
              '.ignore',
              -- ".rgignore"
            },
            hide_hidden = true, -- only works on Windows for hidden files/directories
            hide_by_name = {
              --"node_modules"
            },
            hide_by_pattern = { -- uses glob style patterns
              --"*.meta",
              --"*/src/*/tsconfig.json",
            },
            always_show = { -- remains visible even if other settings would normally hide it
              --".gitignored",
            },
            always_show_by_pattern = { -- uses glob style patterns
              --".env*",
            },
            never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
              '.DS_Store',
              --"thumbs.db"
            },
            never_show_by_pattern = { -- uses glob style patterns
              --".null-ls_*",
            },
          },
          follow_current_file = {
            enabled = false, -- This will find and focus the file in the active buffer every time
            --               -- the current file is changed while the tree is open.
            leave_dirs_open = false, -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
          },
          group_empty_dirs = false, -- when true, empty folders will be grouped together
          hijack_netrw_behavior = 'open_default', -- netrw disabled, opening a directory opens neo-tree
          -- in whatever position is specified in window.position
          -- "open_current",  -- netrw disabled, opening a directory opens within the
          -- window like netrw would, regardless of window.position
          -- "disabled",    -- netrw left alone, neo-tree does not handle opening dirs
          use_libuv_file_watcher = false, -- This will use the OS level file watchers to detect changes
          -- instead of relying on nvim autocmd events.
          window = {
            mappings = {
              ['<bs>'] = 'navigate_up',
              ['.'] = 'set_root',
              ['H'] = 'toggle_hidden',
              ['/'] = 'fuzzy_finder',
              ['D'] = 'fuzzy_finder_directory',
              ['#'] = 'fuzzy_sorter', -- fuzzy sorting using the fzy algorithm
              -- ["D"] = "fuzzy_sorter_directory",
              ['f'] = 'filter_on_submit',
              ['<c-x>'] = 'clear_filter',
              ['[g'] = 'prev_git_modified',
              [']g'] = 'next_git_modified',
              ['o'] = {
                'show_help',
                nowait = false,
                config = { title = 'Order by', prefix_key = 'o' },
              },
              ['oc'] = { 'order_by_created', nowait = false },
              ['od'] = { 'order_by_diagnostics', nowait = false },
              ['og'] = { 'order_by_git_status', nowait = false },
              ['om'] = { 'order_by_modified', nowait = false },
              ['on'] = { 'order_by_name', nowait = false },
              ['os'] = { 'order_by_size', nowait = false },
              ['ot'] = { 'order_by_type', nowait = false },
              -- ['<key>'] = function(state) ... end,
            },
            fuzzy_finder_mappings = { -- define keymaps for filter popup window in fuzzy_finder_mode
              ['<down>'] = 'move_cursor_down',
              ['<C-n>'] = 'move_cursor_down',
              ['<up>'] = 'move_cursor_up',
              ['<C-p>'] = 'move_cursor_up',
              ['<esc>'] = 'close',
              ['<S-CR>'] = 'close_keep_filter',
              ['<C-CR>'] = 'close_clear_filter',
              ['<C-w>'] = { '<C-S-w>', raw = true },
              {
                -- normal mode mappings
                n = {
                  ['j'] = 'move_cursor_down',
                  ['k'] = 'move_cursor_up',
                  ['<S-CR>'] = 'close_keep_filter',
                  ['<C-CR>'] = 'close_clear_filter',
                  ['<esc>'] = 'close',
                },
              },
              -- ["<esc>"] = "noop", -- if you want to use normal mode
              -- ["key"] = function(state, scroll_padding) ... end,
            },
          },

          commands = {}, -- Add a custom command or override a global one using the same function name
        },
        buffers = {
          follow_current_file = {
            enabled = true, -- This will find and focus the file in the active buffer every time
            --              -- the current file is changed while the tree is open.
            leave_dirs_open = false, -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
          },
          group_empty_dirs = true, -- when true, empty folders will be grouped together
          show_unloaded = true,
          window = {
            mappings = {
              ['d'] = 'buffer_delete',
              ['bd'] = 'buffer_delete',
              ['<bs>'] = 'navigate_up',
              ['.'] = 'set_root',
              ['o'] = {
                'show_help',
                nowait = false,
                config = { title = 'Order by', prefix_key = 'o' },
              },
              ['oc'] = { 'order_by_created', nowait = false },
              ['od'] = { 'order_by_diagnostics', nowait = false },
              ['om'] = { 'order_by_modified', nowait = false },
              ['on'] = { 'order_by_name', nowait = false },
              ['os'] = { 'order_by_size', nowait = false },
              ['ot'] = { 'order_by_type', nowait = false },
            },
          },
        },
        git_status = {
          window = {
            position = 'float',
            mappings = {
              ['A'] = 'git_add_all',
              ['gu'] = 'git_unstage_file',
              ['gU'] = 'git_undo_last_commit',
              ['ga'] = 'git_add_file',
              ['gr'] = 'git_revert_file',
              ['gc'] = 'git_commit',
              ['gp'] = 'git_push',
              ['gg'] = 'git_commit_and_push',
              ['o'] = {
                'show_help',
                nowait = false,
                config = { title = 'Order by', prefix_key = 'o' },
              },
              ['oc'] = { 'order_by_created', nowait = false },
              ['od'] = { 'order_by_diagnostics', nowait = false },
              ['om'] = { 'order_by_modified', nowait = false },
              ['on'] = { 'order_by_name', nowait = false },
              ['os'] = { 'order_by_size', nowait = false },
              ['ot'] = { 'order_by_type', nowait = false },
            },
          },
        },
      }
    end,
  },
  {
    'antosha417/nvim-lsp-file-operations',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-neo-tree/neo-tree.nvim', -- makes sure that this loads after Neo-tree.
    },
    config = function()
      require('lsp-file-operations').setup()
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
      'kkharji/sqlite.lua',
      'nvim-telescope/telescope-smart-history.nvim',
    },
    config = function()
      -- See `:help telescope` and `:help telescope.setup()`
      require('telescope').setup {
        -- You can put your default mappings / updates / etc. in here
        --  All the info you're looking for is in `:help telescope.setup()`
        --
        defaults = {
          history = {
            path = '~/.local/share/nvim/databases/telescope_history.sqlite3',
            limit = 100,
          },
          -- TODO: verify that this works
          mappings = {
            i = {
              ['<C-j>'] = require('telescope.actions').cycle_history_next,
              ['<C-Down>'] = require('telescope.actions').cycle_history_next,
              ['<M-j>'] = require('telescope.actions').cycle_history_next,
              ['<M-Down>'] = require('telescope.actions').cycle_history_next,

              ['<C-k>'] = require('telescope.actions').cycle_history_prev,
              ['<C-Up>'] = require('telescope.actions').cycle_history_prev,
              ['<M-k>'] = require('telescope.actions').cycle_history_prev,
              ['<M-Up>'] = require('telescope.actions').cycle_history_prev,
            },
            n = {
              ['<C-j>'] = require('telescope.actions').cycle_history_next,
              ['<C-Down>'] = require('telescope.actions').cycle_history_next,
              ['<M-j>'] = require('telescope.actions').cycle_history_next,
              ['<M-Down>'] = require('telescope.actions').cycle_history_next,

              ['<C-k>'] = require('telescope.actions').cycle_history_prev,
              ['<C-Up>'] = require('telescope.actions').cycle_history_prev,
              ['<M-k>'] = require('telescope.actions').cycle_history_prev,
              ['<M-Up>'] = require('telescope.actions').cycle_history_prev,
            },
          },
        },
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
      pcall(require('telescope').load_extension, 'smart_history')

      -- See `:help telescope.builtin`
      local builtin = require 'telescope.builtin'
      local themes = require 'telescope.themes'
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })

      vim.keymap.set('n', '<leader>p', function()
        builtin.find_files(themes.get_dropdown {
          previewer = false,
        })
      end, { desc = '[S]earch [F]iles' })

      vim.keymap.set('n', '<leader>f', function()
        builtin.live_grep {
          layout_strategy = 'vertical',
        }
      end, { desc = '[F]ind in files' })

      vim.keymap.set('n', '<leader><leader>', function()
        builtin.buffers(themes.get_dropdown {
          previewer = false,
        })
      end, { desc = '[ ] Find existing buffers' })

      vim.keymap.set('n', '<leader>kt', function()
        builtin.colorscheme(themes.get_dropdown {
          previewer = false,
        })
      end, { desc = 'Search themes' })

      -- Slightly advanced example of overriding default behavior and theme
      vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          -- winblend = 10,
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

          vim.keymap.set('n', '<Plug>OriginalGd', 'gd', { silent = true })
          vim.keymap.set('n', 'gd', require('telescope.builtin').lsp_definitions, { desc = '[G]oto [D]efinition' })
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
        -- menu = {
        --   draw = {
        --     columns = {
        --       { 'label', 'label_description', gap = 1 },
        --       { 'kind', 'source_name', gap = 1 },
        --     },
        --   },
        -- },
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
