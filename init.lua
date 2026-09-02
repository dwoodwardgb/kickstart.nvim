--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

--  TODO: consider remapping ; to : for easy commands
vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = 'a'
vim.o.showmode = true
vim.o.wrap = false
vim.opt.fillchars = { eob = '~', fold = ' ', diff = ' ' }
vim.opt.completeopt = { 'menuone', 'noinsert', 'noselect', 'preview', 'popup' }
vim.o.breakat = '^I!@*+;,./?'
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'yes'
vim.o.timeoutlen = 1100
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = '. ', trail = '·', nbsp = '␣' }
vim.o.inccommand = 'nosplit'
vim.o.cursorline = true -- Show which line your cursor is on
vim.o.scrolloff = 2
-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
vim.o.confirm = true

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

vim.g.have_nerd_font = false

vim.filetype.add {
  extension = {
    pp = 'json',
    ftl = 'freemarker',
    ftlh = 'freemarker',
    mdc = 'markdown',
    astro = 'astro',
  },
}

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>') -- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set('n', '<leader>tw', '<cmd>set wrap!<CR>', { desc = '[T]oggle line [W]rap' })
vim.keymap.set('n', '<leader>w', function()
  local buf = vim.api.nvim_get_current_buf()
  local wins = vim.api.nvim_list_wins()

  local alt = vim.fn.bufnr '#'
  local other_buf = nil

  if alt > 0 and alt ~= buf and vim.api.nvim_buf_is_loaded(alt) and vim.bo[alt].buflisted then
    other_buf = alt
  else
    for _, b in ipairs(vim.api.nvim_list_bufs()) do
      if b ~= buf and vim.api.nvim_buf_is_loaded(b) and vim.bo[b].buflisted then
        other_buf = b
        break
      end
    end
  end

  if other_buf then
    for _, win in ipairs(wins) do
      if vim.api.nvim_win_get_buf(win) == buf then
        vim.api.nvim_win_set_buf(win, other_buf)
      end
    end
  else
    vim.cmd 'enew'
  end

  local still_used = false
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == buf then
      still_used = true
      break
    end
  end
  if not still_used then
    vim.cmd('bd ' .. buf)
  end
end, { desc = 'Close current buffer ([W]indow)' })
vim.keymap.set('n', '<leader>W', function()
  -- Resolve the "current" buffer from the focused window, but if focus is in a
  -- special window (nvim-tree sidebar, terminal, floating/which-key, etc.) fall back
  -- to a normal listed buffer so we don't accidentally keep the sidebar and
  -- delete the file you were actually editing.
  local cur = vim.api.nvim_get_current_buf()
  if vim.bo[cur].buftype ~= '' or not vim.bo[cur].buflisted then
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local b = vim.api.nvim_win_get_buf(win)
      if vim.bo[b].buftype == '' and vim.bo[b].buflisted then
        cur = b
        break
      end
    end
  end
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= cur and vim.api.nvim_buf_is_loaded(buf) then
      if vim.bo[buf].buftype == 'terminal' then
        goto continue
      end
      if vim.bo[buf].filetype == 'NvimTree' then
        goto continue
      end
      -- force = false errors on modified buffers; pcall so one unsaved buffer
      -- doesn't abort the loop and leave the rest open.
      pcall(vim.api.nvim_buf_delete, buf, { force = false })
    end
    ::continue::
  end
end, { desc = 'Close all buffers except current' })
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode', silent = true })
vim.keymap.set('t', '<leader><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode', silent = true })
vim.keymap.set('t', '<leader><leader>', '<C-\\><C-n><C-o>', { desc = 'Exit terminal mode', silent = true })
vim.api.nvim_create_autocmd('TermOpen', {
  group = vim.api.nvim_create_augroup('term-nav', { clear = true }),
  callback = function()
    vim.b.term_origin_win = vim.api.nvim_get_current_win()
    vim.keymap.set('n', '<leader><leader>', '<C-\\><C-n><C-o>', { buffer = true, desc = 'Terminal-only normal mode map' })
  end,
})

--  See `:help wincmd` for a list of all window commands
--  TODO: consider using Meta instead of control for ergonomics on real keyboard
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Quickfix and Loclist stuff
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

function _G.ToggleLocList()
  local locListIsOpen = vim.fn.getloclist(0, { winid = 0 }).winid ~= 0
  if locListIsOpen then
    vim.cmd 'lclose'
  else
    vim.diagnostic.setloclist()
  end
end

vim.api.nvim_create_user_command('Lq', function()
  local loclist = vim.fn.getloclist(0)
  vim.fn.setqflist(loclist, 'r')
  vim.cmd 'copen'
end, {})

vim.keymap.set('n', '<leader>q', ':lua ToggleQuickfix()<CR>', { noremap = true, silent = true, desc = 'Toggle [Q]uickfix list' })
-- vim.keymap.set('n', '<leader>l', '<cmd>lopen<CR>', { desc = 'Open diagnostic [L]ocation list' })
vim.keymap.set('n', '<leader>l', ':lua ToggleLocList()<CR>', { noremap = true, silent = true, desc = 'Open diagnostic quickfix [L]ist' })

-- NOTE: here's how to do find and replace w/quickfixlist:
-- :vimgrep /old_function/j **/*.py
-- :cfdo %s/old_function/new_function/g | update

-- TODO: yank, paste, delete without poluting the system clipboard
-- TODO: limit jumplist to file directory and or support jumplist tree or advanced stuff

-- ctrl+` for term toggle
vim.keymap.set('n', '<C-`>', function()
  -- Focus existing terminal window if one is visible
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype == 'terminal' then
      vim.api.nvim_set_current_win(win)
      return
    end
  end
  -- Otherwise find hidden terminal buffer and open it in its origin window
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(b) and vim.bo[b].buftype == 'terminal' then
      local origin = vim.b[b].term_origin_win
      if origin and vim.api.nvim_win_is_valid(origin) then
        vim.api.nvim_set_current_win(origin)
      end
      vim.api.nvim_set_current_buf(b)
      return
    end
  end
  vim.cmd 'terminal'
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

-- Default indent settings, will be overrident by guess-indent
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.softtabstop = 2

-- Autoformat
vim.b.disable_autoformat = false
vim.g.disable_autoformat = false
vim.api.nvim_create_user_command('NoFormatOnSave', function(args)
  if args.bang then
    -- NoFormatOnSave! will disable formatting just for this buffer
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
-- vim.keymap.set('n', '<leader>tf', '<cmd>ToggleFormatOnSave<CR>', { desc = '[T]oggle format on save' })

-- vim.keymap.set('n', '<M-]>', '<cmd>bnext<CR>', { desc = 'Next buffer ]', silent = true })
-- vim.keymap.set('n', '<leader>]', '<cmd>bnext<CR>', { desc = 'Next buffer ]', silent = true })
-- vim.keymap.set('n', '<M-[>', '<cmd>bprev<CR>', { desc = 'Prev buffer [', silent = true })
-- vim.keymap.set('n', '<leader>[', '<cmd>bprev<CR>', { desc = 'Prev buffer [', silent = true })

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
-- Returns `color` tinted by adding dr/dg/db to its RGB channels.
local function tint_color(color, dr, dg, db)
  local r = math.floor(color / 0x10000)
  local g = math.floor(color / 0x100) % 0x100
  local b = color % 0x100
  return math.max(0, math.min(255, r + dr)) * 0x10000 + math.max(0, math.min(255, g + dg)) * 0x100 + math.max(0, math.min(255, b + db))
end

vim.api.nvim_create_autocmd('ColorScheme', {
  pattern = '*',
  callback = function()
    if vim.o.background == 'light' then
      vim.g.terminal_color_8 = '#333333'
    else
      vim.g.terminal_color_8 = '#aaaaaa'
    end

    local raw_bg = vim.api.nvim_get_hl(0, { name = 'Normal' }).bg
    local is_light = vim.o.background == 'light'
    -- Treat unset or dark bg as white in light mode, black in dark mode.
    local function luminance(c)
      return math.floor(c / 0x10000) * 0.299 + math.floor(c / 0x100) % 0x100 * 0.587 + c % 0x100 * 0.114
    end
    local fallback = is_light and 0xffffff or 0x000000
    local normal_bg = (raw_bg and (is_light and luminance(raw_bg) > 64 or not is_light and luminance(raw_bg) < 192)) and raw_bg or fallback
    local offset = is_light and -11 or 10
    vim.api.nvim_set_hl(0, 'Folded', {
      -- fg = vim.api.nvim_get_hl(0, { name = 'Comment' }).fg,
      bg = tint_color(normal_bg, offset, offset, offset),
      -- italic = true,
    })

    if is_light then
      vim.api.nvim_set_hl(0, 'CursorLine', { bg = tint_color(normal_bg, -8, -4, 12) })
    end
  end,
})

vim.api.nvim_create_autocmd('ColorScheme', {
  pattern = 'vim',
  callback = function()
    if vim.o.background == 'light' then
      -- vim sets Pmenu=LightMagenta which bleeds into NormalFloat; use morning's neutral gray instead.
      vim.cmd 'hi Pmenu    ctermfg=Black ctermbg=White guifg=Black guibg=LightGray'
      vim.cmd 'hi SignColumn ctermbg=White ctermfg=Black guibg=White guifg=Black'
      vim.cmd 'hi LineNr ctermfg=DarkGray guifg=DarkGray'
    end
  end,
})

function CustomizeModusTheme() end

vim.api.nvim_create_autocmd('ColorScheme', {
  pattern = 'modus',
  callback = function()
    CustomizeModusTheme()
  end,
})
vim.api.nvim_create_autocmd('OptionSet', {
  pattern = 'background',
  callback = function()
    local theme = vim.g.colors_name
    if theme and string.find(theme, 'modus') ~= nil then
      CustomizeModusTheme()
    end
  end,
})

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)
require('lazy').setup({
  -- Auto theme detection plugin
  {
    -- NOTE: you can use dark-notify if you're only tragetting MacOS. Using this instead because this config is used on Linux sometimes
    'f-person/auto-dark-mode.nvim',
    lazy = false,
    config = function()
      local auto_dark_mode = require 'auto-dark-mode'
      auto_dark_mode.setup {
        update_interval = 5000, -- Check for theme changes every 4 seconds
        set_dark_mode = function()
          vim.cmd.colorscheme 'habamax'
        end,
        set_light_mode = function()
          vim.cmd.colorscheme 'lunaperche'
          -- vim.cmd.colorscheme 'wildcharm'
        end,
      }
    end,
  },
  -- lights themes
  {
    'miikanissi/modus-themes.nvim',
    config = function()
      ---@diagnostic disable-next-line: missing-fields
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
  { 'Verf/deepwhite.nvim' },
  -- dark themes
  {
    -- TODO: remove italics
    'datsfilipe/vesper.nvim',
  },
  -- Using Lazy
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
    -- TODO: remove italics
    'vague-theme/vague.nvim',
  },
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
    lazy = false,
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      -- Dynamic sidebar width, carried over from the old oil sidebar.
      local function tree_width()
        return math.min(59, math.max(40, math.floor(vim.o.columns / 3)))
      end

      -- netrw-mirroring keymaps. The trailing comment on each line is the
      -- netrw key it imitates, so muscle memory transfers to bare netrw.
      local function on_attach(bufnr)
        local api = require 'nvim-tree.api'
        local function opts(desc)
          return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end
        local map = vim.keymap.set
        -- navigation
        map('n', '<CR>', api.node.open.edit, opts 'Open') -- netrw <CR>
        map('n', 'o', api.node.open.horizontal, opts 'Open: horizontal split') -- netrw o
        map('n', 'v', api.node.open.vertical, opts 'Open: vertical split') -- netrw v
        map('n', 't', api.node.open.tab, opts 'Open: new tab') -- netrw t
        map('n', 'P', api.node.open.preview, opts 'Preview') -- netrw p (p is paste here)
        map('n', '-', api.tree.change_root_to_parent, opts 'Up a dir') -- netrw -
        map('n', '<BS>', api.node.navigate.parent_close, opts 'Close dir')
        map('n', 'gh', api.tree.toggle_hidden_filter, opts 'Toggle hidden') -- netrw gh
        map('n', '<C-l>', api.tree.reload, opts 'Refresh') -- netrw <C-l>
        -- file operations
        map('n', 'R', api.fs.rename_full, opts 'Rename: full path') -- netrw R
        map('n', 'r', api.fs.rename, opts 'Rename')
        map('n', '%', api.fs.create, opts 'New file') -- netrw % (end name with / for a dir)
        map('n', 'd', api.fs.create, opts 'New file/dir') -- netrw d
        map('n', 'D', api.fs.remove, opts 'Delete') -- netrw D
        map('n', 'x', api.fs.cut, opts 'Cut')
        map('n', 'c', api.fs.copy.node, opts 'Copy')
        map('n', 'p', api.fs.paste, opts 'Paste')
        map('n', 'y', api.fs.copy.filename, opts 'Copy name')
        map('n', 'Y', api.fs.copy.relative_path, opts 'Copy relative path')
        -- misc
        map('n', 'q', api.tree.close, opts 'Close')
        map('n', '?', api.tree.toggle_help, opts 'Help')
      end

      require('nvim-tree').setup {
        sort = { sorter = 'case_sensitive' },
        view = {
          side = 'right',
          width = tree_width,
        },
        renderer = { group_empty = true },
        filters = { dotfiles = false }, -- show hidden files (matches oil's show_hidden)
        actions = {
          open_file = { quit_on_open = false }, -- sidebar stays open after opening a file
        },
        on_attach = on_attach,
      }

      local api = require 'nvim-tree.api'

      -- Keep the sidebar width sane on terminal resize (old oil VimResized hack).
      vim.api.nvim_create_autocmd('VimResized', {
        callback = function()
          if api.tree.is_visible() then
            api.tree.resize { width = tree_width() }
          end
        end,
      })

      -- <leader>b: 3-state toggle like the old oil sidebar — open when closed,
      -- focus when open-but-unfocused, close when already focused.
      vim.keymap.set('n', '<leader>b', function()
        if not api.tree.is_visible() then
          api.tree.open()
        elseif api.tree.is_tree_buf(vim.api.nvim_get_current_buf()) then
          api.tree.close()
        else
          api.tree.focus()
        end
      end, { desc = 'Toggle nvim-tree sidebar' })

      -- <leader>e: reveal the current file in the tree (opens it if needed).
      vim.keymap.set('n', '<leader>e', function()
        api.tree.find_file { open = true, focus = true }
      end, { desc = 'Reveal current file in tree' })

      -- Update the LSP on move/rename so imports and references follow the file.
      -- rename_full (mapped to R) fires NodeRenamed for both in-place renames and
      -- path-typed moves between folders. NOTE: cut/paste moves (x then p) may not
      -- emit this event, so prefer R for LSP-aware relocations.
      api.events.subscribe(api.events.Event.NodeRenamed, function(data)
        local files = { { oldUri = vim.uri_from_fname(data.old_name), newUri = vim.uri_from_fname(data.new_name) } }
        for _, client in ipairs(vim.lsp.get_clients()) do
          local fileops = vim.tbl_get(client.server_capabilities or {}, 'workspace', 'fileOperations') or {}
          if fileops.willRename then
            local resp = client:request_sync('workspace/willRenameFiles', { files = files }, 1000, 0)
            if resp and resp.result then
              pcall(vim.lsp.util.apply_workspace_edit, resp.result, client.offset_encoding)
            end
          end
          if fileops.didRename then
            client:notify('workspace/didRenameFiles', { files = files })
          end
        end
      end)
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
        -- { '<leader>', mode = { 'n', 'v' } },
        { 'g', mode = { 'n', 'v' } },
        { 'z', mode = { 'n', 'v' } },
        { 'h', mode = { 'n', 'v' } },
        { 't', mode = { 'n' } },
        { '<leader>', mode = { 'n' } },
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
    'tiagovla/scope.nvim',
    config = function()
      require('scope').setup()
    end,
  },
  {
    -- used instead of native findfunc etc for live fuzzy async fuzzy finding
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

      -- Neovim 0.12 no longer inherits cursorline in floating windows
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'TelescopeResults',
        callback = function(args)
          local win = vim.fn.bufwinid(args.buf)
          if win ~= -1 then
            vim.wo[win].cursorline = true
          end
        end,
      })

      -- Enable Telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')
      pcall(require('telescope').load_extension, 'smart_history')
      pcall(require('telescope').load_extension, 'scope')

      local dropdownTheme = {
        previewer = false,
        theme = 'dropdown',

        results_title = false,

        sorting_strategy = 'ascending',
        layout_strategy = 'center',
        layout_config = {
          preview_cutoff = 1, -- Preview should always show (unless previewer = false)

          width = function(_, max_columns, _)
            return math.min(max_columns, 140)
          end,

          height = function(_, _, max_lines)
            return math.min(max_lines, 25)
          end,
        },

        border = true,
        borderchars = {
          prompt = { '─', '│', ' ', '│', '╭', '╮', '│', '│' },
          results = { '─', '│', '─', '│', '├', '┤', '╯', '╰' },
          preview = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
        },
      }

      -- See `:help telescope.builtin`
      local builtin = require 'telescope.builtin'
      local themes = require 'telescope.themes'
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.command_history, { desc = '[S]earch Recent Files ("." for repeat)' })

      vim.keymap.set('n', '<leader>p', function()
        -- NOTE: copied from telescope theme source, probably don't need the explict get_dropdown call since the opts are hardcoded
        builtin.find_files(dropdownTheme)
      end, { desc = '[S]earch [F]iles' })

      vim.keymap.set('n', '<leader>f', function()
        builtin.live_grep {
          layout_strategy = 'vertical',
        }
      end, { desc = '[F]ind in files' })

      vim.keymap.set('n', '<leader><leader>', function()
        builtin.buffers(dropdownTheme)
      end, { desc = '[ ] Find existing buffers' })

      vim.keymap.set('n', '<leader>kt', function()
        builtin.colorscheme(dropdownTheme)
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
          local builtin = require 'telescope.builtin'
          -- local themes = require 'telescope.themes'
          local vertical_opts = {
            layout_strategy = 'vertical',
          }
          vim.keymap.set('n', 'grr', function()
            builtin.lsp_references(vertical_opts)
          end, { desc = '[G]oto [R]eferences' })
          vim.keymap.set('n', 'gri', function()
            builtin.lsp_implementations(vertical_opts)
          end, { desc = '[G]oto [I]mplementation' })
          vim.keymap.set('n', 'grd', function()
            builtin.lsp_definitions(vertical_opts)
          end, { desc = '[G]oto [D]efinition' })
          vim.keymap.set('n', 'grD', vim.lsp.buf.declaration, { desc = '[G]oto [D]eclaration' })
          vim.keymap.set('n', 'gO', function()
            builtin.lsp_document_symbols(vertical_opts)
          end, { desc = 'Open Document Symbols' })
          vim.keymap.set('n', 'gW', function()
            builtin.lsp_dynamic_workspace_symbols(vertical_opts)
          end, { desc = 'Open Workspace Symbols' })
          vim.keymap.set('n', 'grt', function()
            builtin.lsp_type_definitions(vertical_opts)
          end, { desc = '[G]oto [T]ype Definition' })
          vim.keymap.set('n', 'grf', vim.lsp.buf.code_action, { desc = '[G]oto [F]ixes' })

          vim.keymap.set('n', '<Plug>OriginalGd', 'gd', { silent = true })
          vim.keymap.set('n', 'gd', function()
            builtin.lsp_definitions(vertical_opts)
          end, { desc = '[G]oto [D]efinition' })
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
          vim.keymap.set('n', 'T', vim.diagnostic.open_float, { desc = 'Show diagnostic info [T]ooltip' })
          vim.keymap.set('n', '<leader>dq', vim.diagnostic.setqflist, { desc = '[D]iagnostics to [Q]uickfix list' })

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            -- vim.api.nvim_create_autocmd('LspDetach', {
            --   group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
            --   callback = function(event2)
            --     vim.lsp.buf.clear_references()
            --     vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
            --   end,
            -- })
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

          if (client and client.name == 'ts_ls') or (client and client.name == 'vtsls') then
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

      -- JAVA -----------------------------------------------------------------
      local function get_jdtls_cache_dir()
        return vim.fn.stdpath 'cache' .. '/jdtls'
      end
      local function get_jdtls_workspace_dir()
        return get_jdtls_cache_dir() .. '/workspace'
      end
      local function get_jdtls_jvm_args()
        local env = os.getenv 'JDTLS_JVM_ARGS'
        local args = {}
        for a in string.gmatch((env or ''), '%S+') do
          local arg = string.format('--jvm-arg=%s', a)
          table.insert(args, arg)
        end
        return unpack(args)
      end
      local root_markers1 = {
        -- Multi-module projects
        'mvnw', -- Maven
        'gradlew', -- Gradle
        'settings.gradle', -- Gradle
        'settings.gradle.kts', -- Gradle
        -- Use git directory as last resort for multi-module maven projects
        -- In multi-module maven projects it is not really possible to determine what is the parent directory
        -- and what is submodule directory. And jdtls does not break if the parent directory is at higher level than
        -- actual parent pom.xml so propagating all the way to root git directory is fine
        '.git',
      }
      local root_markers2 = {
        -- Single-module projects
        'build.xml', -- Ant
        'pom.xml', -- Maven
        'build.gradle', -- Gradle
        'build.gradle.kts', -- Gradle
      }
      vim.lsp.config('jdtls', {
        ---@param dispatchers? vim.lsp.rpc.Dispatchers
        ---@param config vim.lsp.ClientConfig
        cmd = function(dispatchers, config)
          local workspace_dir = get_jdtls_workspace_dir()
          local data_dir = workspace_dir

          if config.root_dir then
            data_dir = data_dir .. '/' .. vim.fn.fnamemodify(config.root_dir, ':p:h:t')
          end

          local config_cmd = {
            'jdtls',
            '-data',
            data_dir,
            get_jdtls_jvm_args(),
          }

          return vim.lsp.rpc.start(config_cmd, dispatchers, {
            cwd = config.cmd_cwd,
            env = config.cmd_env,
            detached = config.detached,
          })
        end,
        filetypes = { 'java' },
        root_markers = vim.fn.has 'nvim-0.11.3' == 1 and { root_markers1, root_markers2 } or vim.list_extend(root_markers1, root_markers2),
        init_options = {},
      })
      -- JAVA -----------------------------------------------------------------
      vim.lsp.config('solargraph', {
        cmd = { 'solargraph', 'stdio' },
        settings = {
          solargraph = {
            diagnostics = true,
          },
        },
        init_options = { formatting = false },
        filetypes = { 'ruby' },
        root_markers = { 'Gemfile', '.git' },
      })

      -- Typescript --------------------------
      vim.lsp.config('vtsls', {
        settings = {
          typescript = {
            -- Prevents the server from indexing massive dependency or build folders
            preferences = {
              -- Only index files that are actually imported or in the 'include' path
              autoImportFileExcludePatterns = { 'dist', 'build', '.next' },
            },
            tsserver = {
              -- Disabling the separate syntax server saves significant RAM
              useSeparateSyntaxServer = false,
              -- Tells the watcher to ignore these directories entirely
              watchOptions = {
                excludeDirectories = { '**/dist', '**/build', '**/.next' },
              },
            },
          },
          vtsls = {
            autoUseWorkspaceTsdk = true,
            experimental = {
              completion = {
                enableServerSideFuzzyMatch = true,
              },
            },
          },
        },
      })
      -- Typescript --------------------------

      vim.lsp.config('astro_ls', {
        cmd = { 'astro-ls', '--stdio' },
        filetypes = { 'astro' },
        root_markers = { 'astro.config.mjs', 'astro.config.ts', 'package.json' },
        init_options = { typescript = {} },
        before_init = function(params, config)
          -- astro-ls requires an absolute path to a typescript lib dir.
          -- Resolve the workspace root from the initialize params (reliable),
          -- falling back to config.root_dir and cwd.
          local root = config.root_dir
          if not root and params.workspaceFolders and params.workspaceFolders[1] then
            root = vim.uri_to_fname(params.workspaceFolders[1].uri)
          end
          root = root or params.rootPath or vim.fn.getcwd()

          local candidates = {
            vim.fs.joinpath(root, 'node_modules', 'typescript', 'lib'),
          }
          -- Walk up for monorepo/hoisted installs.
          for dir in vim.fs.parents(root .. '/x') do
            table.insert(candidates, vim.fs.joinpath(dir, 'node_modules', 'typescript', 'lib'))
          end

          for _, tsdk in ipairs(candidates) do
            if vim.uv.fs_stat(vim.fs.joinpath(tsdk, 'typescript.js')) then
              config.init_options.typescript.tsdk = tsdk
              return
            end
          end

          vim.schedule(function()
            vim.notify('astro_ls: could not find typescript/lib under ' .. root, vim.log.levels.WARN)
          end)
        end,
      })

      local servers_enabled = {
        'lua_ls',
        'vtsls',
        'gopls',
        -- 'jdtls',
        'solargraph',
        'astro_ls',
      }
      for _, ls in ipairs(servers_enabled) do
        vim.lsp.enable(ls)
      end
    end,
  },
  { -- Autocompletion
    --  Used instead of native vim.lsp.completion, completeopt etc because of result sorting, ranking and deduping
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
        default = {
          'lsp',
          'path',
          'snippets',
          'lazydev',
          -- 'freemarker',
        },
        providers = {
          lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
          -- freemarker = { module = 'custom.freemarker.blink', score_offset = 50 },
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

  { -- stevearc/conform.nvim
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
            timeout_ms = 10000,
            lsp_format = 'fallback',
          }
        end
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        javascript = { 'prettier' },
        typescript = { 'prettier' },
        typescriptreact = { 'prettier' },
        html = { 'prettier' },
        freemarker = { 'prettier' },
        json = { 'prettier' },
        jsonc = { 'prettier' },
        css = { 'prettier' },
        scss = { 'prettier' },
        astro = { 'prettier' },
        nim = { 'nimpretty' },
      },
    },
  },

  -- Highlight todo, notes, etc in comments
  {
    'folke/todo-comments.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
      signs = false,

      -- Optional: point keywords at semantic names (defaults are usually fine)
      keywords = {
        TODO = { color = 'warning' },
        WARN = { color = 'warning' },
        NOTE = { color = 'info' }, -- INFO: is an alt of NOTE
      },

      -- Named colors used by keywords' `color` field.
      -- Order matters: first hl group that yields a usable fg wins, else next, else hex.
      colors = {
        error = {
          'DiagnosticError',
          'ErrorMsg',
          'NvimLightRed', -- some colorschemes; safe to remove if unused
          '#DC2626',
        },
        warning = {
          'DiagnosticWarn',
          'WarningMsg',
          'Special', -- example: try a theme-specific group you like
          '#FBBF24',
        },
        info = {
          -- 'DiagnosticInfo',
          'Title', -- often distinct in schemes that weak DiagnosticInfo
          '#2563EB',
        },
        hint = {
          'DiagnosticHint',
          'Comment', -- subtler NOTE/INFO if you prefer
          '#10B981',
        },
        default = { 'Identifier', '#7C3AED' },
        test = { 'Identifier', '@variable', '#FF00FF' },
      },
    },
  },

  {
    'FabijanZulj/blame.nvim',
    lazy = false,
    config = function()
      require('blame').setup {}

      vim.keymap.set('n', '<leader>gb', '<Cmd>BlameToggle virtual<CR>')
    end,
  },
  {
    'AlexandrosAlexiou/kotlin.nvim',
    ft = 'kotlin',
    config = function()
      local kotlin_lsp_dir = os.getenv 'KOTLIN_LSP_DIR'
      if not kotlin_lsp_dir then
        vim.notify('KOTLIN_LSP_DIR not set', vim.log.levels.ERROR)
        return
      end

      vim.lsp.config.kotlin_ls = {
        cmd = { kotlin_lsp_dir .. '/bin/intellij-server', '--stdio' },
        filetypes = { 'kotlin' },
        root_markers = { 'build.gradle', 'build.gradle.kts', 'settings.gradle', 'settings.gradle.kts', 'pom.xml' },
      }
      vim.lsp.enable 'kotlin_ls'

      require('kotlin.autocommands').setup()
      require('kotlin.autocommands').setup_inlay_hints {
        inlay_hints = {
          enabled = true,
          parameters = true,
          types_property = true,
          types_variable = true,
          function_return = true,
          lambda_return = true,
        },
      }
      require('kotlin.commands').setup()
      require('kotlin.diagnostics').setup()
      require('kotlin.package').setup()
    end,
  },
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = ':TSUpdate',
    branch = 'main',
    config = function()
      local treesitter = require 'nvim-treesitter'

      treesitter.setup()

      local ensure_installed = {
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
        'tsx',
        'jsx',
        'kotlin',
        'java',
        'elixir',
        'eex',
        'dockerfile',
        'cpp',
        'cmake',
        'go',
        'gomod',
        'gosum',
        'gotmpl',
        'python',
        'ruby',
        'rust',
        'astro',
        'svelte',
        'vue',
        'angular',
        'c_sharp',
        'zsh',
        'zig',
        'yaml',
        'xml',
        'toml',
        'sql',
        'scss',
        'javadoc',
        'groovy',
        'graphql',
      }
      treesitter.install(ensure_installed)
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    opts = {
      enable = true,
      multiline_threshold = 1,
      max_lines = 2, -- Keeps signatures from taking over the screen NOTE: should match scrolloff
      mode = 'cursor', -- 'cursor' or 'topline'
      trim_scope = 'outer',
    },
  },
  {
    'tpope/vim-fugitive',
  },
  -- ;; ~/.config/nvim/queries/javascript/context.scm
  --
  -- (function_declaration) @context
  -- (method_definition) @context
  -- (class_declaration) @context
  -- (arrow_function) @context
  --
  -- ;; Notice we are NOT including (if_statement) @context here.
  -- ;; This effectively "disables" if-statements from sticking.

  -- The following comments only work if you have downloaded the kickstart repo, not just copy pasted the
  -- init.lua. If you want these files, they are in the repository, so you can just download them and
  -- place them in the correct locations.

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

-- require 'custom.plugins.init'

-- Extract a file path from the current `git status --short` line.
-- Handles the "XY " status columns, "orig -> dest" renames (returns dest, the
-- name the index tracks), and git's C-quoted paths for spaces / non-ASCII.
local function git_status_path()
  local line = vim.api.nvim_get_current_line()
  local rest = line:match '^..%s+(.+)$' or line
  rest = rest:match '.*%s%-> (.+)$' or rest
  if rest:sub(1, 1) == '"' then
    rest = vim.fn.eval(rest)
  end
  return rest
end

vim.cmd 'packadd nvim.undotree'
vim.keymap.set('n', '<leader>u', '<Cmd>Undotree<CR>')

function myfoldtext()
  local line = vim.fn.getline(vim.v.foldstart):gsub('%s*{{{%d*', '')
  local count = vim.v.foldend - vim.v.foldstart
  return line .. ' +' .. count .. ''
end
vim.o.foldtext = 'v:lua.myfoldtext()'

-- 1. Enhanced 'O' mapping for Quickfix buffers (Handles Missing/New Files)
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'qf',
  callback = function(args)
    vim.keymap.set('n', 'O', function()
      -- Check or prompt for target branch
      local branch = vim.b.diff_target_branch
      if not branch or branch == '' then
        branch = vim.fn.input 'Diff against branch/commit: '
        if branch == '' then
          return
        end
        vim.b.diff_target_branch = branch
      end

      -- Fetch item directly from quickfix list data
      local qf_idx = vim.fn.line '.'
      local qf_list = vim.fn.getqflist()
      local item = qf_list[qf_idx]

      if not item or (item.bufnr == 0 and item.filename == '') then
        return
      end

      -- Open in a new tab and load the file there
      vim.cmd 'tabnew'
      local created = false
      if item.bufnr > 0 then
        vim.cmd('buffer ' .. item.bufnr)
      else
        vim.cmd('edit ' .. vim.fn.fnameescape(item.filename))
        created = true
      end
      local file_buf = vim.api.nvim_get_current_buf()
      local file_win = vim.api.nvim_get_current_win()

      -- Attempt Gvdiffsplit. If file doesn't exist in target branch (e.g. new file),
      -- catch the error and create an empty scratch split to diff against.
      local ok = pcall(function()
        vim.cmd('Gvdiffsplit ' .. branch)
      end)
      local diff_buf
      if ok then
        diff_buf = vim.api.nvim_get_current_buf()
      else
        vim.cmd 'leftabove vnew'
        vim.bo.buftype = 'nofile'
        vim.bo.bufhidden = 'wipe'
        vim.bo.swapfile = false
        vim.cmd('file ' .. vim.fn.fnameescape('[' .. branch .. ': file does not exist]'))
        diff_buf = vim.api.nvim_get_current_buf()
        vim.wo.diff = true
        vim.api.nvim_set_current_win(file_win)
        vim.wo.diff = true
      end

      -- Wipe the tab's diff buffers when the tab is closed, so nothing
      -- lingers in the buffer list. Modified buffers are left alone.
      local tab = vim.api.nvim_get_current_tabpage()
      vim.api.nvim_create_autocmd('TabClosed', {
        pattern = tostring(tab),
        once = true,
        callback = function()
          for _, b in ipairs { created and file_buf or nil, diff_buf } do
            if b and vim.api.nvim_buf_is_valid(b) and not vim.bo[b].modified then
              vim.cmd('silent! bdelete ' .. b.bufnr)
            end
          end
        end,
        desc = 'Clean up diff tab buffers',
      })
    end, {
      buffer = args.buf,
      silent = true,
      desc = 'Open QF item in new tab with Gvdiffsplit (buffers auto-wipe on tab close)',
    })
  end,
})

-- 2. Custom command: :DiffBranch <branch>
vim.api.nvim_create_user_command('DiffBranch', function(opts)
  local branch = opts.args
  if branch == '' then
    return
  end

  vim.cmd('Git difftool --name-status ' .. branch)
  vim.cmd 'copen'
  vim.b.diff_target_branch = branch
end, { nargs = 1 })

-- vim.api.nvim_create_autocmd('OptionSet', {
--   pattern = 'diff',
--   callback = function()
--     if vim.o.diff then
--       vim.o.signcolumn = 'auto:1' -- at most 1 cell
--     else
--       vim.o.signcolumn = 'auto'
--     end
--   end,
-- })

-- require 'call-graph'
