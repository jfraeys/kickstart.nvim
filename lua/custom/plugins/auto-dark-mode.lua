-- Define the function to set custom highlights for both themes
local function set_lsp_highlights(mode)
  if mode == 'dark' then
    -- Monokai color scheme highlight settings
    vim.api.nvim_set_hl(0, 'LspDocumentHighlight', {
      background = '#3e3e3e', -- Darker grey background for subtle effect
      foreground = '#f8f8f2', -- Light text color
      underline = false,
    })
    vim.api.nvim_set_hl(0, 'LspDiagnosticsVirtualTextError', {
      foreground = '#f8f8f2', -- Monokai light foreground for error
    })
    vim.api.nvim_set_hl(0, 'LspDiagnosticsVirtualTextWarning', {
      foreground = '#e9c07f', -- Yellowish for warning in Monokai
    })
    vim.api.nvim_set_hl(0, 'LspDiagnosticsVirtualTextInformation', {
      foreground = '#8be9fd', -- Light cyan for information in Monokai
    })
    vim.api.nvim_set_hl(0, 'LspDiagnosticsVirtualTextHint', {
      foreground = '#50fa7b', -- Greenish for hints in Monokai
    })
  elseif mode == 'light' then
    -- Solarized color scheme highlight settings
    vim.api.nvim_set_hl(0, 'LspDocumentHighlight', {
      background = '#fdf6e3', -- Light background for Solarized Light
      foreground = '#657b83', -- Soft dark text for Solarized Light
      underline = false,
    })
    vim.api.nvim_set_hl(0, 'LspDiagnosticsVirtualTextError', {
      foreground = '#dc322f', -- Red for errors in Solarized
    })
    vim.api.nvim_set_hl(0, 'LspDiagnosticsVirtualTextWarning', {
      foreground = '#b58900', -- Yellow for warnings in Solarized
    })
    vim.api.nvim_set_hl(0, 'LspDiagnosticsVirtualTextInformation', {
      foreground = '#268bd2', -- Blue for information in Solarized
    })
    vim.api.nvim_set_hl(0, 'LspDiagnosticsVirtualTextHint', {
      foreground = '#2aa198', -- Cyan for hints in Solarized
    })
  end
end

return {
  'f-person/auto-dark-mode.nvim',
  opts = {
    update_interval = 2000,
    set_dark_mode = function()
      vim.api.nvim_set_option_value('background', 'dark', {})
      vim.cmd('colorscheme monokai')

      -- Apply custom highlight settings for Monokai
      set_lsp_highlights('dark')
    end,
    set_light_mode = function()
      vim.api.nvim_set_option_value('background', 'light', {})
      vim.cmd('colorscheme solarized')

      -- Apply custom highlight settings for Solarized
      set_lsp_highlights('light')
    end,
  },
}
