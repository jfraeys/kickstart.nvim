return {
  {
    'floaterminal',
    dir = vim.fn.stdpath('config') .. '/lua/plugins',
    config = function()
      require('plugins.floaterminal').setup({
        border = 'rounded',
        title = 'Terminal',
      })
    end,
  },
}
