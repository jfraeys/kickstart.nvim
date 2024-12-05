return {
  'danymat/neogen',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'L3MON4D3/LuaSnip',
  },
  keys = {
    {
      '<leader>nf',
      function()
        require('neogen').generate({ type = 'func' })
      end,
      desc = 'Generate function documentation',
    },
    {
      '<leader>nt',
      function()
        require('neogen').generate({ type = 'type' })
      end,
      desc = 'Generate type documentation',
    },
  },
  config = function()
    require('neogen').setup({
      enabled = true,
      snippet_engine = 'luasnip', -- Using LuaSnip as the snippet engine
    })
  end,
  cond = function()
    -- Only load if Treesitter is installed and available
    return vim.fn.exists(':TSInstall') == 2
  end,
  -- Uncomment next line if you want to follow only stable versions
  -- version = "*"
}

