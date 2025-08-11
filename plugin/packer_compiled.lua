-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function('has', {'nvim-0.5'}) ~= 1 then
  vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
  return
end

vim.api.nvim_command('packadd packer.nvim')

local no_errors, error_msg = pcall(function()

_G._packer = _G._packer or {}
_G._packer.inside_compile = true

local time
local profile_info
local should_profile = false
if should_profile then
  local hrtime = vim.loop.hrtime
  profile_info = {}
  time = function(chunk, start)
    if start then
      profile_info[chunk] = hrtime()
    else
      profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
    end
  end
else
  time = function(chunk, start) end
end

local function save_profiles(threshold)
  local sorted_times = {}
  for chunk_name, time_taken in pairs(profile_info) do
    sorted_times[#sorted_times + 1] = {chunk_name, time_taken}
  end
  table.sort(sorted_times, function(a, b) return a[2] > b[2] end)
  local results = {}
  for i, elem in ipairs(sorted_times) do
    if not threshold or threshold and elem[2] > threshold then
      results[i] = elem[1] .. ' took ' .. elem[2] .. 'ms'
    end
  end
  if threshold then
    table.insert(results, '(Only showing plugins that took longer than ' .. threshold .. ' ms ' .. 'to load)')
  end

  _G._packer.profile_output = results
end

time([[Luarocks path setup]], true)
local package_path_str = "/Users/david.i.woodward/.cache/nvim/packer_hererocks/2.1.1753364724/share/lua/5.1/?.lua;/Users/david.i.woodward/.cache/nvim/packer_hererocks/2.1.1753364724/share/lua/5.1/?/init.lua;/Users/david.i.woodward/.cache/nvim/packer_hererocks/2.1.1753364724/lib/luarocks/rocks-5.1/?.lua;/Users/david.i.woodward/.cache/nvim/packer_hererocks/2.1.1753364724/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/Users/david.i.woodward/.cache/nvim/packer_hererocks/2.1.1753364724/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

time([[Luarocks path setup]], false)
time([[try_loadstring definition]], true)
local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s), name, _G.packer_plugins[name])
  if not success then
    vim.schedule(function()
      vim.api.nvim_notify('packer.nvim: Error running ' .. component .. ' for ' .. name .. ': ' .. result, vim.log.levels.ERROR, {})
    end)
  end
  return result
end

time([[try_loadstring definition]], false)
time([[Defining packer_plugins]], true)
_G.packer_plugins = {
  ["conform.nvim"] = {
    config = { "\27LJ\2\n¡\2\0\0\5\0\14\0\0176\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\f\0005\3\4\0005\4\3\0=\4\5\0035\4\6\0=\4\a\0035\4\b\0=\4\t\0035\4\n\0=\4\v\3=\3\r\2B\0\2\1K\0\1\0\21formatters_by_ft\1\0\1\21formatters_by_ft\0\bnim\1\2\0\0\14nimpretty\15typescript\1\2\1\0\rprettier\21stop_after_first\2\15javascript\1\2\1\0\rprettier\21stop_after_first\2\blua\1\0\4\15javascript\0\15typescript\0\blua\0\bnim\0\1\2\0\0\vstylua\nsetup\fconform\frequire\0" },
    loaded = true,
    path = "/Users/david.i.woodward/.local/share/nvim/site/pack/packer/start/conform.nvim",
    url = "https://github.com/stevearc/conform.nvim"
  },
  ["guess-indent.nvim"] = {
    config = { "\27LJ\2\n:\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\17guess-indent\frequire\0" },
    loaded = true,
    path = "/Users/david.i.woodward/.local/share/nvim/site/pack/packer/start/guess-indent.nvim",
    url = "https://github.com/NMAC427/guess-indent.nvim"
  },
  ["mini.pick"] = {
    config = { "\27LJ\2\n7\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\14mini.pick\frequire\0" },
    loaded = true,
    path = "/Users/david.i.woodward/.local/share/nvim/site/pack/packer/start/mini.pick",
    url = "https://github.com/echasnovski/mini.pick"
  },
  ["nvim-lspconfig"] = {
    config = { "\27LJ\2\nŒ\1\0\0\3\0\a\0\0216\0\0\0009\0\1\0009\0\2\0'\2\3\0B\0\2\0016\0\0\0009\0\1\0009\0\2\0'\2\4\0B\0\2\0016\0\0\0009\0\1\0009\0\2\0'\2\5\0B\0\2\0016\0\0\0009\0\1\0009\0\2\0'\2\6\0B\0\2\1K\0\1\0\nts_ls\19nim_langserver\vlua_ls\ngopls\venable\blsp\bvim\0" },
    loaded = true,
    path = "/Users/david.i.woodward/.local/share/nvim/site/pack/packer/start/nvim-lspconfig",
    url = "https://github.com/neovim/nvim-lspconfig"
  },
  ["nvim-tree.lua"] = {
    config = { "\27LJ\2\n…\5\0\0\a\0\25\0\0296\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\0025\3\6\0=\3\a\0025\3\t\0005\4\b\0=\4\n\0035\4\16\0005\5\f\0005\6\v\0=\6\r\0055\6\14\0=\6\15\5=\5\17\0045\5\18\0005\6\19\0=\6\15\0055\6\20\0=\6\21\5=\5\22\4=\4\23\3=\3\24\2B\0\2\1K\0\1\0\rrenderer\nicons\vglyphs\bgit\1\0\a\runstaged\bâœ—\14untracked\bâ˜…\frenamed\bâžœ\fdeleted\5\runmerged\6!\fignored\bâ—Œ\vstaged\bâœ“\1\0\b\fdefault\5\topen\6V\nempty\5\15arrow_open\6V\fsymlink\5\17arrow_closed\6>\15empty_open\6V\17symlink_open\6V\1\0\a\bgit\0\rmodified\bâ—\rbookmark\tó°†¤\fsymlink\5\fdefault\5\vfolder\0\vhidden\tó°œŒ\17web_devicons\1\0\2\17web_devicons\0\vglyphs\0\vfolder\1\0\2\venable\1\ncolor\2\tfile\1\0\2\tfile\0\vfolder\0\1\0\2\venable\1\ncolor\2\19indent_markers\1\0\2\19indent_markers\0\nicons\0\1\0\1\venable\2\ffilters\1\0\1\rdotfiles\1\tview\1\0\3\ffilters\0\rrenderer\0\tview\0\1\0\1\tside\nright\nsetup\14nvim-tree\frequire\0" },
    loaded = true,
    path = "/Users/david.i.woodward/.local/share/nvim/site/pack/packer/start/nvim-tree.lua",
    url = "https://github.com/nvim-tree/nvim-tree.lua"
  },
  ["nvim-treesitter"] = {
    config = { "\27LJ\2\n\1\0\2\t\0\a\1\21*\2\0\0006\3\0\0006\5\1\0009\5\2\0059\5\3\0056\6\1\0009\6\4\0069\6\5\6\18\b\1\0B\6\2\0A\3\1\3\15\0\3\0X\5\a€\15\0\4\0X\5\5€9\5\6\4\1\2\5\0X\5\2€+\5\2\0L\5\2\0K\0\1\0\tsize\22nvim_buf_get_name\bapi\ffs_stat\tloop\bvim\npcall€À>á\2\1\0\5\0\n\0\r6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\0025\3\6\0003\4\a\0=\4\b\3=\3\t\2B\0\2\1K\0\1\0\14highlight\fdisable\0\1\0\3&additional_vim_regex_highlighting\1\venable\2\fdisable\0\21ensure_installed\1\0\4\17auto_install\2\17sync_install\1\21ensure_installed\0\14highlight\0\1\17\0\0\6c\blua\bvim\vvimdoc\nquery\rmarkdown\20markdown_inline\truby\15typescript\15javascript\btsx\bcss\tscss\bnim\bzig\thtml\nsetup\28nvim-treesitter.configs\frequire\0" },
    loaded = true,
    path = "/Users/david.i.woodward/.local/share/nvim/site/pack/packer/start/nvim-treesitter",
    url = "https://github.com/nvim-treesitter/nvim-treesitter"
  },
  ["packer.nvim"] = {
    loaded = true,
    path = "/Users/david.i.woodward/.local/share/nvim/site/pack/packer/start/packer.nvim",
    url = "https://github.com/wbthomason/packer.nvim"
  }
}

time([[Defining packer_plugins]], false)
-- Config for: guess-indent.nvim
time([[Config for guess-indent.nvim]], true)
try_loadstring("\27LJ\2\n:\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\17guess-indent\frequire\0", "config", "guess-indent.nvim")
time([[Config for guess-indent.nvim]], false)
-- Config for: nvim-tree.lua
time([[Config for nvim-tree.lua]], true)
try_loadstring("\27LJ\2\n…\5\0\0\a\0\25\0\0296\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\0025\3\6\0=\3\a\0025\3\t\0005\4\b\0=\4\n\0035\4\16\0005\5\f\0005\6\v\0=\6\r\0055\6\14\0=\6\15\5=\5\17\0045\5\18\0005\6\19\0=\6\15\0055\6\20\0=\6\21\5=\5\22\4=\4\23\3=\3\24\2B\0\2\1K\0\1\0\rrenderer\nicons\vglyphs\bgit\1\0\a\runstaged\bâœ—\14untracked\bâ˜…\frenamed\bâžœ\fdeleted\5\runmerged\6!\fignored\bâ—Œ\vstaged\bâœ“\1\0\b\fdefault\5\topen\6V\nempty\5\15arrow_open\6V\fsymlink\5\17arrow_closed\6>\15empty_open\6V\17symlink_open\6V\1\0\a\bgit\0\rmodified\bâ—\rbookmark\tó°†¤\fsymlink\5\fdefault\5\vfolder\0\vhidden\tó°œŒ\17web_devicons\1\0\2\17web_devicons\0\vglyphs\0\vfolder\1\0\2\venable\1\ncolor\2\tfile\1\0\2\tfile\0\vfolder\0\1\0\2\venable\1\ncolor\2\19indent_markers\1\0\2\19indent_markers\0\nicons\0\1\0\1\venable\2\ffilters\1\0\1\rdotfiles\1\tview\1\0\3\ffilters\0\rrenderer\0\tview\0\1\0\1\tside\nright\nsetup\14nvim-tree\frequire\0", "config", "nvim-tree.lua")
time([[Config for nvim-tree.lua]], false)
-- Config for: conform.nvim
time([[Config for conform.nvim]], true)
try_loadstring("\27LJ\2\n¡\2\0\0\5\0\14\0\0176\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\f\0005\3\4\0005\4\3\0=\4\5\0035\4\6\0=\4\a\0035\4\b\0=\4\t\0035\4\n\0=\4\v\3=\3\r\2B\0\2\1K\0\1\0\21formatters_by_ft\1\0\1\21formatters_by_ft\0\bnim\1\2\0\0\14nimpretty\15typescript\1\2\1\0\rprettier\21stop_after_first\2\15javascript\1\2\1\0\rprettier\21stop_after_first\2\blua\1\0\4\15javascript\0\15typescript\0\blua\0\bnim\0\1\2\0\0\vstylua\nsetup\fconform\frequire\0", "config", "conform.nvim")
time([[Config for conform.nvim]], false)
-- Config for: mini.pick
time([[Config for mini.pick]], true)
try_loadstring("\27LJ\2\n7\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\14mini.pick\frequire\0", "config", "mini.pick")
time([[Config for mini.pick]], false)
-- Config for: nvim-lspconfig
time([[Config for nvim-lspconfig]], true)
try_loadstring("\27LJ\2\nŒ\1\0\0\3\0\a\0\0216\0\0\0009\0\1\0009\0\2\0'\2\3\0B\0\2\0016\0\0\0009\0\1\0009\0\2\0'\2\4\0B\0\2\0016\0\0\0009\0\1\0009\0\2\0'\2\5\0B\0\2\0016\0\0\0009\0\1\0009\0\2\0'\2\6\0B\0\2\1K\0\1\0\nts_ls\19nim_langserver\vlua_ls\ngopls\venable\blsp\bvim\0", "config", "nvim-lspconfig")
time([[Config for nvim-lspconfig]], false)
-- Config for: nvim-treesitter
time([[Config for nvim-treesitter]], true)
try_loadstring("\27LJ\2\n\1\0\2\t\0\a\1\21*\2\0\0006\3\0\0006\5\1\0009\5\2\0059\5\3\0056\6\1\0009\6\4\0069\6\5\6\18\b\1\0B\6\2\0A\3\1\3\15\0\3\0X\5\a€\15\0\4\0X\5\5€9\5\6\4\1\2\5\0X\5\2€+\5\2\0L\5\2\0K\0\1\0\tsize\22nvim_buf_get_name\bapi\ffs_stat\tloop\bvim\npcall€À>á\2\1\0\5\0\n\0\r6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\0025\3\6\0003\4\a\0=\4\b\3=\3\t\2B\0\2\1K\0\1\0\14highlight\fdisable\0\1\0\3&additional_vim_regex_highlighting\1\venable\2\fdisable\0\21ensure_installed\1\0\4\17auto_install\2\17sync_install\1\21ensure_installed\0\14highlight\0\1\17\0\0\6c\blua\bvim\vvimdoc\nquery\rmarkdown\20markdown_inline\truby\15typescript\15javascript\btsx\bcss\tscss\bnim\bzig\thtml\nsetup\28nvim-treesitter.configs\frequire\0", "config", "nvim-treesitter")
time([[Config for nvim-treesitter]], false)

_G._packer.inside_compile = false
if _G._packer.needs_bufread == true then
  vim.cmd("doautocmd BufRead")
end
_G._packer.needs_bufread = false

if should_profile then save_profiles() end

end)

if not no_errors then
  error_msg = error_msg:gsub('"', '\\"')
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
