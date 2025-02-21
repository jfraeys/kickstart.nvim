return {
  -- Fuzzy Finder (files, LSP, etc.)
  'nvim-telescope/telescope.nvim',
  event = 'VimEnter',
  branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'debugloop/telescope-undo.nvim', -- Undo history extension
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      config = function()
        require('telescope').setup({
          extensions = {
            fzf = {},
          },
        })
        require('telescope').load_extension('fzf')
      end,
      cond = function()
        return vim.fn.executable('make') == 1
      end,
    },
    'nvim-tree/nvim-web-devicons', -- Optional: Icons for UI
    'mbbill/undotree', -- Undotree dependency
    -- 'b0o/schemastore.nvim', -- YAML schema support
  },
  config = function()
    local telescope = require('telescope')

    -- Configure Telescope
    telescope.setup({
      defaults = {
        -- prompt_prefix = '🔍 ',
        sorting_strategy = 'descending',
        layout_strategy = 'flex',
        mappings = {
          i = {
            ['<C-u>'] = false, -- Disable Ctrl+u clearing input
            ['<C-d>'] = false, -- Disable Ctrl+d clearing input
          },
        },
      },
      extensions = {
        undo = {
          use_delta = true, -- Use delta for better diff visualization
        },
      },
    })

    -- Load the undo extension for Telescope
    telescope.load_extension('undo')

    -- Load yaml schemas for Telescope
    -- telescope.load_extension('yaml_schema')

    -- Key mapping to open undotree directly
    vim.keymap.set('n', '<leader>u', ':UndotreeToggle<CR>', { desc = 'Toggle UndoTree' })

    -- Function to find git root directory
    local function find_git_root()
      local current_file = vim.api.nvim_buf_get_name(0)
      local current_dir = current_file ~= '' and vim.fn.fnamemodify(current_file, ':h') or vim.fn.getcwd()
      local git_root =
        vim.fn.systemlist('git -C ' .. vim.fn.escape(current_dir, ' ') .. ' rev-parse --show-toplevel')[1]

      if vim.v.shell_error ~= 0 then
        print('Not a git repository, searching in current directory.')
        return vim.fn.getcwd()
      end
      return git_root
    end

    -- Function for live_grep within the Git root
    local function live_grep_git_root()
      local git_root = find_git_root()
      if git_root then
        require('telescope.builtin').live_grep({ search_dirs = { git_root } })
      end
    end

    -- Command to trigger live_grep_git_root
    vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, { desc = 'Live grep in Git root' })
  end,
}
