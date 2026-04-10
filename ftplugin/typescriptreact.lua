vim.treesitter.start()
vim.bo.syntax = 'off'
vim.wo.foldmethod = 'expr'
vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.wo.foldlevel = 10
vim.o.colorcolumn = '+1'
vim.o.textwidth = 120
