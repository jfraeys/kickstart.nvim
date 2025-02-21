vim.opt_local.expandtab = true -- Use spaces instead of tabs
vim.opt_local.tabstop = 4 -- Number of spaces per tab
vim.opt_local.shiftwidth = 4 -- Number of spaces for indentation
vim.opt_local.softtabstop = 4 -- Number of spaces to act like a tab
vim.opt_local.formatoptions:remove('o') -- Remove 'o' to avoid automatic comment continuation

vim.api.nvim_create_user_command('RunC', function()
  vim.cmd('w') -- Save the current file
  local filename = vim.fn.expand('%') -- Get current file name
  local output = 'bin/' .. vim.fn.expand('%:r'):match('([^/]+)$') .. '.out' -- Output file with .out extension
  print('Output file: ' .. output)
  vim.fn.mkdir('bin', 'p')
  vim.cmd('!gcc ' .. filename .. ' -o ' .. output .. ' && ./' .. output)
end, {})
