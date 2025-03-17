-- Ensure this file runs only for JSON
if vim.bo.filetype ~= 'json' then
  return
end

-- Use 2 spaces for indentation
vim.bo.shiftwidth = 2
vim.bo.tabstop = 2
vim.bo.expandtab = true

vim.bo.textwidth = 100
vim.wo.wrap = false

-- Automatically format JSON on save (requires `jq` installed)
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*.json',
  callback = function()
    vim.cmd([[ %!jq . ]])
  end,
})

-- Enable spell-check for JSON comments
vim.wo.spell = true

-- Enable Folding for JSON
vim.wo.foldmethod = 'syntax'

-- Set conceal level for better JSON readability (e.g., hiding quotes)
vim.wo.conceallevel = 2
