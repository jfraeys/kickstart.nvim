return {
  'mbbill/undotree',
  config = function()
    -- Set Undotree to open on the right side
    vim.g.undotree_WindowLayout = 4

    vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle, { desc = '[U]ndotree' })
  end,
}
