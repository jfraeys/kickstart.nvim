return {
  'folke/zen-mode.nvim',
  command = 'ZenMode',
  opts = {
    window = {
      backdrop = 0.95, -- Transparency level for the zen mode window
      width = 0.65, -- 80% of the total editor width
      height = 1, -- Full height
      options = {
        signcolumn = 'no', -- Hide signcolumn in zen mode
        number = true, -- Disable line numbers
        relativenumber = true, -- Disable relative numbers
      },
    },
    plugins = {
      wezterm = {
        enabled = true,
        font = '+2', -- Increase font size in WezTerm by 2
      },
    },
    on_open = function()
      -- Configure Neovim options when Zen Mode opens
      vim.opt.ruler = false -- Hide ruler
      vim.opt.showcmd = false -- Hide command feedback
      vim.opt.laststatus = 0 -- Hide status line
    end,
    on_close = function()
      -- Restore Neovim options when Zen Mode closes
      vim.opt.ruler = true -- Show ruler
      vim.opt.showcmd = true -- Show command feedback
      vim.opt.laststatus = 2 -- Show status line
    end,
  },
  keys = {
    {
      '<leader>zz',
      '<cmd>ZenMode<CR>',
      desc = 'Toggle Zen Mode',
      silent = true,
    },
  },
}
