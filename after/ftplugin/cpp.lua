vim.opt_local.cinoptions = vim.opt_local.cinoptions + '0{1' -- Places opening brace on the same line as function signature
vim.opt_local.smartindent = true -- Automatically adds indentation where needed
vim.opt_local.tabstop = 4 -- Set tab stop to 4 spaces
vim.opt_local.shiftwidth = 4 -- Set shift width to 4 spaces
vim.opt_local.softtabstop = 4 -- Use spaces instead of tabs

vim.api.nvim_create_user_command('RunCpp', function(opts)
  vim.cmd('w') -- Save the current file
  local filename = vim.fn.expand('%') -- Get current file name
  local output = 'bin/' .. vim.fn.expand('%:r'):match('([^/]+)$') .. '.out' -- Output file with .out extension

  -- Use provided compiler or default to 'clang++'
  local compiler = opts.args ~= '' and opts.args or 'clang++'

  -- Ensure the output directory exists
  vim.fn.mkdir('bin', 'p')

  -- Compile and run the C++ code
  vim.cmd('!' .. compiler .. ' ' .. filename .. ' -o ' .. output .. ' && ./' .. output)
end, { nargs = '?' }) -- Accepts one optional argument for the compiler
