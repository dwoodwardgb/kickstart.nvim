vim.treesitter.start()
vim.bo.syntax = 'off'
vim.wo.foldmethod = 'expr'
vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.wo.foldlevel = 99
vim.wo.wrap = true
-- vim.bo.textwidth = 80
-- vim.o.formatoptions:append 'tc'
vim.wo.linebreak = true
