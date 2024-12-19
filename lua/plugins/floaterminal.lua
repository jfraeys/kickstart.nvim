local M = {}

-- State to manage the floating terminal
M.state = {
  floating = {
    buf = -1,
    win = -1,
  },
}

-- Helper function to validate a window
local function is_valid_window(win)
  return win and vim.api.nvim_win_is_valid(win)
end

-- Helper function to validate a buffer
local function is_valid_buffer(buf)
  return buf and vim.api.nvim_buf_is_valid(buf)
end

-- Create or update the floating terminal
local function create_floating_terminal(opts)
  opts = opts or {}

  -- Calculate dimensions and position
  local width = opts.width or math.floor(vim.o.columns * 0.8)
  local height = opts.height or math.floor(vim.o.lines * 0.8)
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  -- Ensure buffer is valid or create a new one
  local buf = is_valid_buffer(opts.buf) and opts.buf or vim.api.nvim_create_buf(false, true)

  -- Window configuration
  local win_config = {
    relative = 'editor',
    width = width,
    height = height,
    col = col,
    row = row,
    style = 'minimal',
    border = opts.border or 'rounded',
    title = opts.title or 'Terminal',
    title_pos = 'center',
  }

  -- Create the floating window
  local ok, win = pcall(vim.api.nvim_open_win, buf, true, win_config)
  if not ok then
    vim.notify('Failed to create floating window: ' .. win, vim.log.levels.ERROR)
    return nil
  end

  return { buf = buf, win = win }
end

-- Toggle the floating terminal
function M.toggle_terminal(opts)
  opts = opts or {}

  if not is_valid_window(M.state.floating.win) then
    -- Create and initialize the floating terminal
    M.state.floating = create_floating_terminal({
      buf = M.state.floating.buf,
      width = opts.width,
      height = opts.height,
      border = opts.border,
      title = opts.title,
    })

    if M.state.floating and is_valid_buffer(M.state.floating.buf) then
      -- Ensure the buffer is a terminal
      local buf = M.state.floating.buf
      if vim.bo[buf].buftype ~= 'terminal' then
        vim.api.nvim_set_current_buf(buf)
        vim.cmd('startinsert')
        vim.fn.termopen(os.getenv('SHELL') or 'sh')
      end
    end
  else
    -- Close the floating window
    pcall(vim.api.nvim_win_close, M.state.floating.win, true)
    M.state.floating.win = nil
  end
end

-- Setup function to initialize the module
function M.setup(opts)
  opts = opts or {}

  -- Create a user command for toggling the terminal
  vim.api.nvim_create_user_command('FloatTermToggle', function()
    M.toggle_terminal(opts)
  end, {})

  -- Apply key mappings
  M.keys(opts.mapping)
end

-- Apply key mappings
function M.keys(mapping)
  local default_keymap = {
    ['<leader>ft'] = {
      mode = { 'n', 't' },
      cmd = '<CMD>FloatTermToggle<CR>',
      options = { noremap = true, silent = true, desc = 'Toggle floating terminal' },
    },
  }

  -- Use custom or default mappings
  local keymaps = mapping or default_keymap

  for key, map in pairs(keymaps) do
    if map.desc then
      map.options = vim.tbl_extend('force', map.options or {}, { desc = map.desc })
    end

    for _, mode in ipairs(map.mode) do
      pcall(vim.keymap.del, mode, key)
    end

    vim.keymap.set(map.mode, key, map.cmd, map.options)
  end
end

return M
