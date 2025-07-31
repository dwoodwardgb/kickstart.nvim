vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et

vim.keymap.set("n", "<leader>[", vim.cmd.tabprev)
vim.keymap.set("n", "<leader>]", vim.cmd.tabnext)
vim.opt.scrolloff = 5
vim.opt.relativenumber = true
vim.cmd [[colorscheme modus]]
vim.wo.fillchars = 'eob: '

-- vim.keymap.set("n", "<leader>qq", ":enew<bar>bd #<CR>")
-- vim.keymap.set("n", "<leader>w", ":bd #<CR>")
-- TODO: find a way to switch to the empty buffer, there should only be one
vim.keymap.set("n", "<leader>w", ":Explore<CR>")
