return {
  'jpalardy/vim-slime',
  ft = { 'python' },
  keys = {
    { '<leader>rC', '<cmd>SlimeConfig<cr>', desc = 'Slime Config' },
    {
      '<leader>rr',
      function()
        local is_ipython_open = require('custom.user.ipython_utils').is_ipython_open
        -- Only send cell if IPython is open
        if is_ipython_open() then
          vim.cmd('<Plug>SlimeSendCell<BAR>/^# %%<CR>')
        else
          vim.notify('No IPython REPL found. Open an IPython terminal first.', vim.log.levels.WARN)
        end
      end,
      desc = 'Slime Send Cell',
    },
    {
      '<leader>rr',
      function()
        -- Only send cell if IPython is open
        if is_ipython_open() then
          vim.cmd("<cmd><C-u>'<,'>SlimeSend<CR>")
        else
          vim.notify('No IPython REPL found. Open an IPython terminal first.', vim.log.levels.WARN)
        end
      end,
      mode = 'v',
      desc = 'Slime Send Cell',
    },
    init = function()
      vim.g.slime_target = 'neovim'
      vim.g.slime_no_mappings = true
    end,
    config = function()
      -- Slime configuration
      vim.g.slime_cell_delimiter = '# %%'
      vim.g.slime_bracketed_paste = 1
      vim.g.slime_paste_file = os.getenv('HOME') .. '/.slime_paste'
      vim.g.slime_input_pid = false
      vim.g.slime_suggest_default = true
      vim.g.slime_menu_config = false
      vim.g.slime_neovim_ignore_unlisted = false
      vim.g.slime_python_ipython = 1
    end,
  },
}
