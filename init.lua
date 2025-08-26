--[[

Lua guide: https://learnxinyminutes.com/docs/lua/
Neovim tutor: run ":Tutor"
Search help keymap: "<space>sh" to [s]earch the [h]elp documentation
If you experience any errors while trying to install kickstart, run `:checkhealth` for more info.

--]]

vim.o.wrap = false
vim.opt.fillchars = { eob = ' ' }
vim.opt.completeopt = { 'menuone', 'noinsert', 'noselect', 'preview', 'popup' }
vim.opt.breakat = '^I!@*+;,./?'

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.o.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
vim.o.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.o.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.o.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- TODO: consider remapping ; to : for easy commands

-- TODO: figure out how to disable for / search, but enable case for grep, ripgrep etc
-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
-- vim.o.ignorecase = true
-- vim.o.smartcase = true

-- Keep signcolumn on by default
vim.o.signcolumn = 'yes'

-- Decrease update time
-- vim.o.updatetime = 250

-- Decrease mapped sequence wait time
-- vim.o.timeoutlen = 300

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
--
--  Notice listchars is set using `vim.opt` instead of `vim.o`.
--  It is very similar to `vim.o` but offers an interface for conveniently interacting with tables.
--   See `:help lua-options`
--   and `:help lua-options-guide`
vim.o.list = true
-- vim.opt.listchars = { tab = '. ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.o.inccommand = 'split'

-- Show which line your cursor is on
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 5

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

vim.keymap.set('n', '<leader>tw', '<cmd>set wrap!<CR>', { desc = '[T]oggle line [W]rap' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
-- vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
-- vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
-- vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
-- vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

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

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
-- NOTE: Here is where you install your plugins.
require('lazy').setup({
  install = { colorscheme = { 'default' } },
  -- Auto theme detection plugin
  {
    -- TODO: use dark notify instead
    'f-person/auto-dark-mode.nvim',
    config = function()
      local auto_dark_mode = require 'auto-dark-mode'
      auto_dark_mode.setup {
        update_interval = 2000, -- Check for theme changes every 2 seconds
        set_dark_mode = function()
          vim.cmd.colorscheme 'kanagawa-dragon'
        end,
        set_light_mode = function()
          vim.cmd.colorscheme 'light-chromeclipse'
          -- vim.cmd.colorscheme 'default'
        end,
      }
    end,
  },
  -- lights themes
  { 'shaunsingh/seoul256.nvim' },
  { 'ronisbr/nano-theme.nvim' },
  { 'kepano/flexoki-neovim' },
  { 'rayes0/blossom.vim' },
  { 'p00f/alabaster.nvim' },
  { 'josebalius/vim-light-chromeclipse' },
  -- dark themes
  { 'frenzyexists/aquarium-vim' },
  { 'ficd0/ashen.nvim' },
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

  -- NOTE: Plugins can also be configured to run Lua code when they are loaded.
  --
  -- This is often very useful to both group configuration, as well as handle
  -- lazy loading plugins that don't need to be loaded immediately at startup.
  --
  -- For example, in the following configuration, we use:
  --  event = 'VimEnter'
  --
  -- which loads which-key before all the UI elements are loaded. Events can be
  -- normal autocommands events (`:help autocmd-events`).
  --
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

  { -- Fuzzy Finder (files, lsp, etc)
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
      -- The easiest way to use Telescope, is to start by doing something like:
      --  :Telescope help_tags
      -- You'll see a list of `help_tags` options and a corresponding preview of the help.
      --
      -- Two important keymaps to use while in Telescope are:
      --  - Insert mode: <c-/>
      --  - Normal mode: ?
      --
      -- This opens a window that shows you all of the keymaps for the current
      -- Telescope picker. This is really useful to discover what Telescope can
      -- do as well as how to actually do it!
      local a = vim.api
      local popup = require 'plenary.popup'
      local utils = require 'telescope.utils'
      local Layout = require 'telescope.pickers.layout'
      local function default_create_layout(picker)
        -- HACK: whitelist of prompt titles we use to apply the custom layout tweaks to
        local is_vertical = (picker.prompt_title == 'Live Grep' or picker.prompt_title:find('Find Word', 1, true) == 1 or picker.prompt_title == 'Oldfiles')

        local function make_border(border)
          if not border then
            return nil
          end
          border.winid = border.win_id
          return border
        end

        local layout = Layout {
          picker = picker,
          ---@param self TelescopeLayout
          mount = function(self)
            local line_count = vim.o.lines - vim.o.cmdheight
            if vim.o.laststatus ~= 0 then
              line_count = line_count - 1
            end

            if is_vertical then
              -- HACK: use the full window height for vertical layouts
              line_count = line_count + 3
            end

            local popup_opts = picker:get_window_options(vim.o.columns, line_count)

            -- HACK: force it to be fullscreen and have only one border between neighbors like border collapse in table css
            if is_vertical then
              popup_opts.preview.line = popup_opts.preview.line - 1
              popup_opts.preview.height = popup_opts.preview.height + 1
              popup_opts.preview.width = popup_opts.preview.width + 2
              popup_opts.preview.border = { 0, 0, 0, 0 }
              popup_opts.results.height = popup_opts.results.height + 1
              popup_opts.results.width = popup_opts.results.width + 2
              popup_opts.results.border = { 1, 0, 0, 1 }
              popup_opts.prompt.line = popup_opts.prompt.line + 1
              popup_opts.prompt.width = popup_opts.prompt.width + 2
              popup_opts.prompt.border = { 1, 0, 0, 1 }
            end

            popup_opts.results.focusable = true
            popup_opts.results.minheight = popup_opts.results.height
            popup_opts.results.highlight = 'TelescopeResultsNormal'
            popup_opts.results.borderhighlight = 'TelescopeResultsBorder'
            popup_opts.results.titlehighlight = 'TelescopeResultsTitle'
            popup_opts.prompt.minheight = popup_opts.prompt.height
            popup_opts.prompt.highlight = 'TelescopePromptNormal'
            popup_opts.prompt.borderhighlight = 'TelescopePromptBorder'
            popup_opts.prompt.titlehighlight = 'TelescopePromptTitle'

            if popup_opts.preview then
              popup_opts.preview.focusable = true
              popup_opts.preview.minheight = popup_opts.preview.height
              popup_opts.preview.highlight = 'TelescopePreviewNormal'
              popup_opts.preview.borderhighlight = 'TelescopePreviewBorder'
              popup_opts.preview.titlehighlight = 'TelescopePreviewTitle'
            end

            local results_win, results_opts = picker:_create_window('', popup_opts.results)
            local results_bufnr = a.nvim_win_get_buf(results_win)

            self.results = Layout.Window {
              winid = results_win,
              bufnr = results_bufnr,
              border = make_border(results_opts.border),
            }

            if popup_opts.preview then
              local preview_win, preview_opts = picker:_create_window('', popup_opts.preview)
              local preview_bufnr = a.nvim_win_get_buf(preview_win)

              self.preview = Layout.Window {
                winid = preview_win,
                bufnr = preview_bufnr,
                border = make_border(preview_opts.border),
              }
            end

            local prompt_win, prompt_opts = picker:_create_window('', popup_opts.prompt)
            local prompt_bufnr = a.nvim_win_get_buf(prompt_win)

            self.prompt = Layout.Window {
              winid = prompt_win,
              bufnr = prompt_bufnr,
              border = make_border(prompt_opts.border),
            }
          end,
          ---@param self TelescopeLayout
          unmount = function(self)
            utils.win_delete('results_win', self.results.winid, true, true)
            if self.preview then
              utils.win_delete('preview_win', self.preview.winid, true, true)
            end

            utils.win_delete('prompt_border_win', self.prompt.border.winid, true, true)
            utils.win_delete('results_border_win', self.results.border.winid, true, true)
            if self.preview then
              utils.win_delete('preview_border_win', self.preview.border.winid, true, true)
            end

            -- we cant use win_delete. We first need to close and then delete the buffer
            if vim.api.nvim_win_is_valid(self.prompt.winid) then
              vim.api.nvim_win_close(self.prompt.winid, true)
            end
            vim.schedule(function()
              utils.buf_delete(self.prompt.bufnr)
            end)
          end,
          ---@param self TelescopeLayout
          update = function(self)
            local line_count = vim.o.lines - vim.o.cmdheight
            if vim.o.laststatus ~= 0 then
              line_count = line_count - 1
            end

            local popup_opts = picker:get_window_options(vim.o.columns, line_count)
            -- `popup.nvim` massaging so people don't have to remember minheight shenanigans
            popup_opts.results.minheight = popup_opts.results.height
            popup_opts.prompt.minheight = popup_opts.prompt.height
            if popup_opts.preview then
              popup_opts.preview.minheight = popup_opts.preview.height
            end

            local prompt_win = self.prompt.winid
            local results_win = self.results.winid
            local preview_win = self.preview and self.preview.winid

            local preview_opts
            if popup_opts.preview then
              if preview_win ~= nil then
                -- Move all popups at the same time
                popup.move(prompt_win, popup_opts.prompt)
                popup.move(results_win, popup_opts.results)
                popup.move(preview_win, popup_opts.preview)
              else
                popup_opts.preview.focusable = true
                popup_opts.preview.highlight = 'TelescopePreviewNormal'
                popup_opts.preview.borderhighlight = 'TelescopePreviewBorder'
                popup_opts.preview.titlehighlight = 'TelescopePreviewTitle'
                local preview_bufnr = (self.preview and self.preview.bufnr ~= nil) and vim.api.nvim_buf_is_valid(self.preview.bufnr) and self.preview.bufnr
                  or ''
                preview_win, preview_opts = picker:_create_window(preview_bufnr, popup_opts.preview)
                if preview_bufnr == '' then
                  preview_bufnr = a.nvim_win_get_buf(preview_win)
                end
                self.preview = Layout.Window {
                  winid = preview_win,
                  bufnr = preview_bufnr,
                  border = make_border(preview_opts.border),
                }
                if picker.previewer and picker.previewer.state and picker.previewer.state.winid then
                  picker.previewer.state.winid = preview_win
                end

                -- Move prompt and results after preview created
                vim.defer_fn(function()
                  popup.move(prompt_win, popup_opts.prompt)
                  popup.move(results_win, popup_opts.results)
                end, 0)
              end
            elseif preview_win ~= nil then
              popup.move(prompt_win, popup_opts.prompt)
              popup.move(results_win, popup_opts.results)

              -- Remove preview after the prompt and results are moved
              vim.defer_fn(function()
                utils.win_delete('preview_win', preview_win, true)
                utils.win_delete('preview_win', self.preview.border.winid, true)
                self.preview = nil
              end, 0)
            else
              popup.move(prompt_win, popup_opts.prompt)
              popup.move(results_win, popup_opts.results)
            end
          end,
        }

        return layout
      end
      require('telescope').setup {
        defaults = {
          path_display = {
            truncate = 0,
            -- shorten = { len = 1, exclude = { 1, 2, -2, -1 } }, -- these were set with the fellowship monorepo in mind
          },
          -- borderchars = { '─', '', '', '', '', '', '', '' },
          -- layout_strategy = 'vertical',
          layout_config = {
            horizontal = {
              width = 0.85,
              height = 0.85,
              preview_width = 0.6,
            },
            vertical = {
              width = 0.999,
              height = 0.999,
              preview_height = 0.5,
            },
          },
          create_layout = default_create_layout,
        },
        extensions = {
          -- TODO: what does this do?
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
      vim.keymap.set('n', '<leader>sf', function()
        builtin.find_files(require('telescope.themes').get_dropdown {
          previewer = false,
        })
      end, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      -- TODO: figure out how to search exactly by case etc (non fuzzy)
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader><leader>', function()
        builtin.buffers(require('telescope.themes').get_dropdown {
          previewer = false,
        })
      end, { desc = '[ ] Find existing buffers' })
      vim.keymap.set('n', '<leader>st', function()
        builtin.colorscheme(require('telescope.themes').get_dropdown {
          previewer = false,
        })
      end, { desc = '[S]earch [T]hemes' })

      vim.keymap.set('n', '<leader>sw', function()
        builtin.grep_string {
          borderchars = { '─', '', '', '', '', '', '', '' },
          layout_strategy = 'vertical',
        }
      end, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', function()
        builtin.live_grep {
          borderchars = { '─', '', '', '', '', '', '', '' },
          layout_strategy = 'vertical',
        }
      end, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>s.', function()
        builtin.oldfiles {
          borderchars = { '─', '', '', '', '', '', '', '' },
          layout_strategy = 'vertical',
        }
      end, { desc = '[S]earch Recent Files ("." for repeat)' })

      -- TODO: add builtin for cached searches/pickers see https://www.reddit.com/r/neovim/comments/phndpv/can_telescope_remember_my_last_search_result/

      -- Slightly advanced example of overriding default behavior and theme
      vim.keymap.set('n', '<leader>/', function()
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
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
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Useful status updates for LSP.
      { 'j-hui/fidget.nvim', opts = {} },
      -- Allows extra capabilities provided by blink.cmp
      'saghen/blink.cmp',
    },
    config = function()
      -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
      -- and elegantly composed help section, `:help lsp-vs-treesitter`

      --  This function gets run when an LSP attaches to a particular buffer.
      --    That is to say, every time a new file is opened that is associated with
      --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
      --    function will be executed to configure the current buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          -- NOTE: Remember that Lua is a real programming language, and as such it is possible
          -- to define small helper and utility functions so you don't have to repeat yourself.
          --
          -- In this case, we create a function that lets us more easily define mappings specific
          -- for LSP related items. It sets the mode, buffer and description for us each time.
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map('grn', vim.lsp.buf.rename, '[R]e[n]ame')

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })

          -- Find references for the word under your cursor.
          map('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          map('gri', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

          -- Jump to the definition of the word under your cursor.
          --  This is where a variable was first declared, or where a function is defined, etc.
          --  To jump back, press <C-t>.
          map('grd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- Fuzzy find all the symbols in your current document.
          --  Symbols are things like variables, functions, types, etc.
          map('gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')

          -- Fuzzy find all the symbols in your current workspace.
          --  Similar to document symbols, except searches over your entire project.
          map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')

          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map('grt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')

          -- Custom hover on K
          map('K', vim.lsp.buf.hover, 'Hover')

          -- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
          ---@param client vim.lsp.Client
          ---@param method vim.lsp.protocol.Method
          ---@param bufnr? integer some lsp support methods only in specific files
          ---@return boolean
          local function client_supports_method(client, method, bufnr)
            if vim.fn.has 'nvim-0.11' == 1 then
              return client:supports_method(method, bufnr)
            else
              return client.supports_method(method, { bufnr = bufnr })
            end
          end

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

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
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
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
        } or {},
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

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add blink.cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with blink.cmp, and then broadcast that to the servers.
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --
      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
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
      local servers_enabled = {
        'lua_ls',
        'ts_ls',
        'gopls',
      }
      for _, ls in ipairs(servers_enabled) do
        vim.lsp.enable(ls)
      end
    end,
  },

  { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
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
        if disable_filetypes[vim.bo[bufnr].filetype] then
          return nil
        else
          return {
            timeout_ms = 900,
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
        puppet = { 'prettier' },
      },
    },
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
      'folke/lazydev.nvim',
    },
    --- @module 'blink.cmp'
    --- @type blink.cmp.Config
    opts = {
      keymap = {
        -- enter to select, see https://cmp.saghen.dev/configuration/keymap.html#presets for details
        -- TODO: figure out how to trigger with ctrl-space in insert mode
        preset = 'enter',
        -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
        --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
      },

      appearance = {
        -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'mono',
      },

      completion = {
        -- By default, you may press `<c-space>` to show the documentation.
        -- Optionally, set `auto_show = true` to show the documentation after a delay.
        documentation = { auto_show = false, auto_show_delay_ms = 500 },
        list = {
          -- kind of like select,noinsert
          selection = { preselect = true, auto_insert = false },
        },
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
    },
  },

  -- Highlight todo, notes, etc in comments
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()

      -- Simple and easy statusline.
      --  You could remove this setup call if you don't like it,
      --  and try some other statusline plugin
      local statusline = require 'mini.statusline'
      -- set use_icons to true if you have a Nerd Font
      statusline.setup { use_icons = vim.g.have_nerd_font }

      -- You can configure sections in the statusline by overriding their
      -- default behavior. For example, here we set the section for
      -- cursor location to LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end

      -- ... and there is more!
      --  Check out: https://github.com/echasnovski/mini.nvim
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function(opts)
      require('nvim-treesitter.configs').setup(opts)
      vim.o.foldmethod = 'expr'
      vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
      vim.o.foldlevel = 99
    end,
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
        'javascript',
        'typescript',
        'tsx',
        'nim',
        'json',
        'css',
        'scss',
        'ruby',
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
  require 'kickstart.plugins.neo-tree',
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

-- Force .pp to be treated as puppet files, not Pascal
-- NOTE: used AI, could be wrong
-- TODO: decide if BufEnter is the best trigger
vim.api.nvim_create_autocmd('BufEnter', {
  pattern = '*.pp',
  callback = function()
    -- Only set if it's not already set, to avoid infinite loops or unnecessary work
    if vim.bo.filetype ~= 'puppet' then
      vim.bo.filetype = 'puppet'
      -- print("Debug: .pp set to puppet (BufEnter fallback)")
    end
  end,
  desc = 'Force .pp files to puppet (BufEnter fallback)',
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
