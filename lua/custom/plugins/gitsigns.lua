return {
  'lewis6991/gitsigns.nvim',
  opts = {
    -- Git sign characters
    signs = {
      add = { text = '+' },
      change = { text = '~' },
      delete = { text = '_' },
      topdelete = { text = '‾' },
      changedelete = { text = '~' },
    },
    -- Function called when plugin attaches to a buffer
    on_attach = function(bufnr)
      -- Always show the sign column
      vim.opt.signcolumn = 'yes'

      -- Keybindings
      local gs = require('gitsigns')
      vim.keymap.set('n', '<leader>hp', gs.preview_hunk, {
        buffer = bufnr,
        desc = 'Preview git hunk',
      })

      vim.keymap.set({ 'n', 'v' }, ']c', function()
        if vim.wo.diff then
          return ']c'
        end
        vim.schedule(function()
          gs.next_hunk()
        end)
        return '<Ignore>'
      end, { expr = true, buffer = bufnr, desc = 'Jump to next hunk' })

      vim.keymap.set({ 'n', 'v' }, '[c', function()
        if vim.wo.diff then
          return '[c'
        end
        vim.schedule(function()
          gs.prev_hunk()
        end)
        return '<Ignore>'
      end, { expr = true, buffer = bufnr, desc = 'Jump to previous hunk' })
    end,
  },
}
