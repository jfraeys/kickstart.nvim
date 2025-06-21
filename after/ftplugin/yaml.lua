-- Set indentation for YAML files
vim.bo.shiftwidth = 2
vim.bo.tabstop = 2
vim.bo.expandtab = true

-- Set text width to 80 to auto-break lines when formatting
vim.bo.textwidth = 80

-- Automatically trim trailing spaces when saving
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*.yml,*.yaml',
  command = [[%s/\s\+$//e]],
})

-- Add '---' at start if missing on save
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*.yml',
  callback = function()
    local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
    if first_line ~= '---' then
      vim.api.nvim_buf_set_lines(0, 0, 0, false, { '---' })
    end
  end,
})

-- Highlight current line
vim.wo.cursorline = true
