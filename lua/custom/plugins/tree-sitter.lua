return {
  -- Highlight, edit, and navigate code
  'nvim-treesitter/nvim-treesitter',
  dependencies = {
    'nvim-treesitter/nvim-treesitter-textobjects',
    'https://github.com/apple/pkl-neovim.git',
  },
  build = ':TSUpdate',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local ts = require('nvim-treesitter.configs')
    ts.setup({
      ensure_installed = {
        'bash',
        'c',
        'cpp',
        'lua',
        'python',
        'go',
        'markdown',
        'markdown_inline',
        'r',
        'rust',
        'vimdoc',
        'vim',
        'yaml',
        'query',
      },
      ignore_install = {}, -- Example: Ignore Haskell if not needed
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { 'markdown' },
      },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = 'gnn',
          node_incremental = 'grn',
          scope_incremental = 'grc',
          node_decremental = 'grm',
        },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ['aa'] = '@parameter.outer',
            ['ia'] = '@parameter.inner',
            ['af'] = '@function.outer',
            ['if'] = '@function.inner',
            ['ac'] = '@class.outer',
            ['ic'] = '@class.inner',
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            [']m'] = '@function.outer',
            [']]'] = '@class.outer',
          },
          goto_next_end = {
            [']M'] = '@function.outer',
            [']['] = '@class.outer',
          },
          goto_previous_start = {
            ['[m'] = '@function.outer',
            ['[['] = '@class.outer',
          },
          goto_previous_end = {
            ['[M'] = '@function.outer',
            ['[]'] = '@class.outer',
          },
        },
        swap = {
          enable = true,
          swap_next = {
            ['<leader>i'] = '@parameter.inner',
          },
          swap_previous = {
            ['<leader>I'] = '@parameter.inner',
          },
        },
      },
      refactor = {
        highlight_definitions = { enable = true },
        highlight_current_scope = { enable = true },
        smart_rename = {
          enable = true,
          keymaps = {
            smart_rename = 'grr',
          },
        },
      },
    })
  end,
}
