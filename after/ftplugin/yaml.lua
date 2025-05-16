-- yaml.lua ftplugin

-- Set indentation for YAML files
vim.bo.shiftwidth = 2 -- Set spaces per indentation level
vim.bo.tabstop = 2 -- Set the width of a tab character
vim.bo.expandtab = true -- Use spaces instead of tabs

-- Automatically trim trailing spaces when saving a YAML file
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*.yml,*.yaml',
  command = [[%s/\s\+$//e]], -- Remove trailing spaces
})

-- Prevent adding a newline at the end of YAML files
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'yaml',
  callback = function()
    vim.opt_local.fileformat = 'unix' -- Ensure it's using Unix line endings
    vim.opt_local.eol = false -- Prevent newline at the end of the file
  end,
})

vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*.yml',
  callback = function()
    local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
    if first_line ~= '---' then
      vim.api.nvim_buf_set_lines(0, 0, 0, false, { '---' })
    end
  end,
})

vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*.yaml',
  callback = function()
    local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
    if first_line ~= '---' then
      vim.api.nvim_buf_set_lines(0, 0, 0, false, { '---' })
    end
  end,
})

-- Enable folding based on YAML indentation (helps with structured files)
vim.wo.foldmethod = 'indent' -- Enable folding based on indentation
vim.wo.foldlevel = 99 -- Expand all folds by default

-- Optionally, highlight the current line for better readability
vim.wo.cursorline = true -- Highlight the current line in the buffer
