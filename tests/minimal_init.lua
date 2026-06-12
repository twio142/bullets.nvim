local lazy = vim.fn.stdpath("data") .. "/lazy"
vim.opt.rtp:prepend(lazy .. "/plenary.nvim")
vim.opt.rtp:prepend(vim.fn.getcwd())

vim.cmd("runtime plugin/plenary.vim")
