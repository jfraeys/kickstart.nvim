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

-- Disable hover from Ruff LSP if active
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp_attach_disable_ruff_hover', { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == 'ruff' then
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

-- Open a Python terminal in a right-hand split and start ipython
vim.keymap.set('n', '<leader>rp', function()
  local screen_width_percentage = 25
  -- Helper function to find an existing terminal buffer
  local function find_terminal_buffer()
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].buftype == 'terminal' then
        return bufnr
      end
    end
    return nil
  end

  -- Helper function to focus or toggle a terminal window
  local function toggle_terminal_window(bufnr)
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(win) == bufnr then
        -- Hide the terminal if it's visible
        vim.api.nvim_win_hide(win)
        return
      end
    end

    -- Open the terminal in a new vertical split
    vim.cmd('vsplit')
    vim.api.nvim_win_set_buf(0, bufnr)
    vim.cmd.wincmd('L') -- Move to the right split
    vim.api.nvim_win_set_width(0, math.floor(vim.o.columns / (100 / screen_width_percentage)))
  end

  -- Helper function to create a new terminal
  local function create_terminal()
    vim.cmd('vnew') -- Open a new vertical split
    vim.cmd('term') -- Open a terminal in the new split
    vim.cmd.wincmd('L') -- Move the split to the right

    -- Set the width of the terminal split
    vim.api.nvim_win_set_width(0, math.floor(vim.o.columns / (100 / screen_width_percentage)))

    -- Send 'ipython' command once terminal is ready
    local job_id = vim.b.terminal_job_id
    if job_id then
      vim.defer_fn(function()
        vim.fn.chansend(job_id, 'ipython\n')
      end, 100)
    else
      vim.notify('Failed to start terminal job.', vim.log.levels.ERROR)
    end
  end

  -- Main logic: toggle or create the terminal
  local term_bufnr = find_terminal_buffer()
  if term_bufnr then
    toggle_terminal_window(term_bufnr)
  else
    create_terminal()
  end
end, { desc = 'Toggle Python REPL Terminal' })
