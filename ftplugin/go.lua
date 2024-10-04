-- Set buffer-local options for Go files
vim.bo.expandtab = true -- Use spaces instead of tabs
vim.bo.commentstring = '// %s' -- Comment format for Go
vim.opt_local.comments = 's1:/*,mb:*,ex:*/,://'

-- Define a buffer-local key mapping to trigger Go debugging
vim.keymap.set('n', '<leader>td', function()
  require('dap-go').debug_test()
end, { buffer = 0, desc = 'Debug Go Test' }) -- Buffer-local key mapping

-- Load nvim-dap-go and set up configurations
require('dap-go').setup()

-- Go DAP configuration
local dap = require('dap')

-- Define Go DAP configurations
dap.configurations.go = {
  {
    type = 'go',
    name = 'Launch File',
    request = 'launch',
    program = '${file}',
  },
  {
    type = 'go',
    name = 'Launch Package',
    request = 'launch',
    program = '${workspaceFolder}',
  },
}
