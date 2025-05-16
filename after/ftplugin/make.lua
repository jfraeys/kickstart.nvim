-- Ensure this file runs only for Makefiles
if vim.bo.filetype ~= 'make' then
  return
end

-- Use tabs for indentation (Makefiles require tabs in rules)
vim.bo.expandtab = false
vim.bo.shiftwidth = 4
vim.bo.tabstop = 4
vim.bo.softtabstop = 4

-- Show trailing spaces and tabs explicitly for visibility
vim.wo.list = true
vim.opt.listchars:append({ tab = '→ ', trail = '·' })

-- Disable automatic comment continuation
vim.opt_local.formatoptions:remove('o')

-- Highlight spaces before tabs (helps detect incorrect indentation)
vim.cmd([[ match Error /^\s\+\t/ ]])

-- Enable line numbers for better navigation
vim.wo.number = true

-- Disable spell checking for Makefiles
vim.wo.spell = false

-- Set conceal level to 0 (Makefiles don't need concealment)
vim.wo.conceallevel = 0
