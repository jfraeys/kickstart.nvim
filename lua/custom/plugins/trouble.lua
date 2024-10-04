return {
  'folke/trouble.nvim',
  cmd = 'TroubleToggle', -- Use TroubleToggle to toggle the Trouble window
  opts = {
    auto_open = false, -- Automatically open Trouble when diagnostics exist
    auto_close = true, -- Automatically close Trouble when diagnostics are cleared
    auto_preview = true, -- Preview diagnostic location on hover
    auto_fold = true, -- Automatically fold diagnostics items
    use_diagnostic_signs = true, -- Use LSP diagnostic signs
    icons = true, -- Enable icons for better UI visuals
    padding = true, -- Add padding around the Trouble window
  },
  keys = {
    { '<leader>tt', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Toggle Trouble' },
    { '<leader>tb', '<cmd>Trouble diagnostics toggle focus.buf=0<cr>', desc = 'Toggle Buffer Diagnostics' },
    { '<leader>tl', '<cmd>Trouble loclist<cr>', desc = 'Loclist' },
    { '<leader>tq', '<cmd>Trouble quickfix<cr>', desc = 'Quickfix' },
  },
}
