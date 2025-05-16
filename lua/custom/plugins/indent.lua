local highlight = {
  'Whitespace',
  'Function',
}

return {
  -- Add indentation guides even on blank lines
  'lukas-reineke/indent-blankline.nvim',
  main = 'ibl',
  opts = {
    indent = {
      highlight = highlight,
      char = '┆',
    },
    whitespace = {
      highlight = highlight,
      remove_blankline_trail = true,
    },
    scope = {
      enabled = true,
      exclude = { language = { 'vim', 'lua', 'go', 'python', 'rust', 'sh', 'json', 'yaml', 'toml', 'markdown' } },
    },
  },
}
