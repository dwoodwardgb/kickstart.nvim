-- vim.bo.shiftwidth = 4
-- vim.bo.tabstop = 4
-- vim.bo.softtabstop = 4

vim.treesitter.start()
vim.bo.syntax = 'off'
vim.opt_local.foldmethod = 'expr'
vim.opt_local.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt_local.foldlevel = 99
