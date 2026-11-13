vim.treesitter.start()
vim.bo.syntax = 'off'
vim.opt_local.foldmethod = 'expr'
vim.opt_local.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt_local.foldlevel = 10
vim.o.colorcolumn = '+1'
vim.o.textwidth = 120
