-- Enable tab settings for the current file type
vim.opt_local.expandtab = false   -- Use actual tab characters, not spaces
vim.opt_local.shiftwidth = 4      -- Width of an indentation level
vim.opt_local.softtabstop = 4     -- Number of spaces tabs count for when editing
vim.opt_local.tabstop = 4         -- Number of columns occupied by a tab character
vim.opt_local.textwidth = 80      -- Max line width for this file type

-- Enable syntax highlighting
vim.opt_local.syntax = "enable"

