return {
  'stevearc/oil.nvim',
  dependencies = {
    'nvim-tree/nvim-web-devicons', -- optional, for file icons
  },
  config = function()
    local oil = require('oil')

    oil.setup({
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
      float = {
        padding = 2,
        max_width = 80,
        max_height = 30,
        border = 'rounded',
        win_options = {
          winblend = 0,
        },
        relative = 'editor',
      },
    })

    -- Monokai-like highlights
    vim.api.nvim_set_hl(0, 'OilDir', { fg = '#A6E22E' })
    vim.api.nvim_set_hl(0, 'OilFile', { fg = '#D3D0C8' })
    vim.api.nvim_set_hl(0, 'OilHiddenFile', { fg = '#75715E' })
    vim.api.nvim_set_hl(0, 'OilProgress', { fg = '#66D9EF' })
    vim.api.nvim_set_hl(0, 'OilSymlink', { fg = '#F92672' })

    -- Oil keymaps
    vim.keymap.set('n', '<leader>e', '<CMD>Oil<CR>', { noremap = true, silent = true, desc = 'Open parent directory' })
    vim.keymap.set('n', '<leader>E', function()
      oil.toggle_float()
    end, { noremap = true, silent = true, desc = 'Toggle oil floating window' })

    -- Add selected file in oil.nvim to Harpoon
    vim.keymap.set('n', '<leader>ah', function()
      local ok_harpoon, harpoon = pcall(require, 'harpoon')
      if not ok_harpoon then
        vim.notify('Harpoon not found', vim.log.levels.WARN)
        return
      end

      local entry = oil.get_cursor_entry()
      if not entry or not entry.name then
        vim.notify('No valid entry selected in Oil', vim.log.levels.INFO)
        return
      end

      local full_path = oil.get_current_dir() .. entry.name
      local stat = vim.loop.fs_stat(full_path)
      if not stat or stat.type ~= 'file' then
        vim.notify('Selected entry is not a file: ' .. full_path, vim.log.levels.INFO)
        return
      end

      harpoon:list():add({
        value = entry.name,
        context = { filename = entry.name, cwd = oil.get_current_dir() or 'global' },
      })
    end, { desc = 'Add selected file in oil.nvim to Harpoon' })
  end,
}
