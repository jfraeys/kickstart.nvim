local M = {}

-- Function to check if an IPython REPL is open in Neovim panes
function M.is_ipython_open()
  for _, winnr in ipairs(vim.api.nvim_list_wins()) do
    local bufnr = vim.api.nvim_win_get_buf(winnr)
    -- Check if it's a terminal buffer
    if
      vim.api.nvim_get_option_value('buftype', { buf = bufnr }) == 'terminal'
      and vim.api.nvim_buf_is_loaded(bufnr)
    then
      -- Get first few lines to check if it's an IPython REPL
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 10, false)
      for _, line in ipairs(lines) do
        -- Specific checks for IPython
        if
          line:match('IPython') -- IPython banner
          or line:match('In %[%d+%]:') -- IPython input prompt
          or line:match('In %[')
        then -- Alternative IPython prompt
          return true
        end
      end
    end
  end
  return false
end

return M
