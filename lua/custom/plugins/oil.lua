return {
  'stevearc/oil.nvim',
  dependencies = {
    'nvim-tree/nvim-web-devicons', -- Lazy dependency for devicons
  },
  config = function()
    require('oil').setup({
      columns = {
        'icon',
        -- 'permissions',
      },
      keymaps = {
        ['C-h'] = false,
        ['M-h'] = 'actions.select_split',
      },
      view_options = {
        show_hidden = true,
      },
    })

    -- Custom Monokai Dark font colors for oil.nvim
    vim.api.nvim_set_hl(0, 'OilDir', { fg = '#A6E22E' }) -- Directory color (green)
    vim.api.nvim_set_hl(0, 'OilFile', { fg = '#D3D0C8' }) -- File color (light beige)
    vim.api.nvim_set_hl(0, 'OilHiddenFile', { fg = '#75715E' }) -- Hidden file color (muted green)
    vim.api.nvim_set_hl(0, 'OilProgress', { fg = '#66D9EF' }) -- Progress color (cyan)
    vim.api.nvim_set_hl(0, 'OilSymlink', { fg = '#F92672' }) -- Symlink color (pink)

    -- Keymaps
    vim.keymap.set('n', '-', '<CMD>Oil<CR>', { noremap = true, silent = true, desc = 'Open parent directory' })
    vim.keymap.set('n', '<leader>-', function()
      require('oil').toggle_float()
    end, { noremap = true, silent = true, desc = 'Toggle oil floating window' })
  end,
}
