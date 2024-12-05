-- Set buffer-local options for Python files
vim.opt_local.expandtab = true -- Use spaces instead of tabs
vim.opt_local.commentstring = '# %s' -- Python comment format
vim.opt_local.smarttab = true -- Enable smart tab
vim.opt_local.shiftwidth = 4 -- Indent width
vim.opt_local.tabstop = 4 -- Tab width
vim.opt_local.softtabstop = 4 -- Soft tab width for alignment
vim.opt_local.fileformat = 'unix' -- Use Unix line endings
vim.opt_local.textwidth = 79 -- Maximum text width
vim.opt_local.colorcolumn = '80' -- Highlight column 80

-- Python DAP configuration
local dap = require('dap')

-- Function to determine the Python interpreter path
local function get_python_path()
  local cwd = vim.fn.getcwd()
  if vim.env.VIRTUAL_ENV then
    return vim.env.VIRTUAL_ENV .. '/bin/python' -- Use virtual environment if set
  elseif vim.fn.executable(cwd .. '/venv/bin/python') == 1 then
    return cwd .. '/venv/bin/python' -- Use project-specific venv
  elseif vim.fn.executable(cwd .. '/.venv/bin/python') == 1 then
    return cwd .. '/.venv/bin/python' -- Use hidden project venv
  else
    return 'python' -- Fallback to system Python
  end
end

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp_attach_disable_ruff_hover', { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client == nil then
      return
    end
    if client.name == 'ruff' then
      -- Disable hover in favor of Pyright
      client.server_capabilities.hoverProvider = false
    end
  end,
  desc = 'LSP: Disable hover capability from Ruff',
})

-- Set up dap-python with the detected Python interpreter
require('dap-python').setup(get_python_path())

-- Define Python DAP configurations
dap.configurations.python = {
  {
    type = 'python',
    request = 'launch',
    name = 'Launch Program',
    program = '${file}', -- Launch the current file
    console = 'integratedTerminal', -- Use the integrated terminal for I/O
  },
  {
    type = 'python',
    request = 'launch',
    name = 'Profile Memory',
    program = '${file}', -- Launch the current file with profiling
    args = { '--profile-memory' }, -- Additional argument for memory profiling
  },
}
