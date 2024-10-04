return {
  'tpope/vim-fugitive',
  config = function()
    -- General key mappings for Fugitive
    vim.keymap.set('n', '<leader>gs', vim.cmd.Git, { desc = 'Open Git status' })

    -- Create an autocommand group for Fugitive-specific settings
    local fugitive_augroup = vim.api.nvim_create_augroup('fugitive', { clear = true })

    -- Set up autocommands for Fugitive buffers
    vim.api.nvim_create_autocmd('BufWinEnter', {
      group = fugitive_augroup,
      pattern = '*',
      callback = function()
        if vim.bo.filetype ~= 'fugitive' then
          return
        end

        local bufnr = vim.api.nvim_get_current_buf()
        local opts = { buffer = bufnr, remap = false }

        -- Key mappings specific to Fugitive buffers
        vim.keymap.set('n', '<leader>p', function()
          vim.cmd.Git('push')
        end, opts)
        vim.keymap.set('n', '<leader>P', function()
          vim.cmd.Git('pull --rebase')
        end, opts)
        vim.keymap.set('n', '<leader>t', ':Git push -u origin ', opts)
      end,
    })

    -- Additional key mappings for resolving Git conflicts
    vim.keymap.set('n', 'gu', '<cmd>diffget //2<CR>', { desc = 'Get diff for version 2' })
    vim.keymap.set('n', 'gh', '<cmd>diffget //3<CR>', { desc = 'Get diff for version 3' })

    -- Create a custom user command for Git operations
    vim.api.nvim_create_user_command('Git', function(params)
      vim.cmd('Git ' .. params.args)
    end, { nargs = '*' })
  end,
  cond = function()
    -- Conditional loading based on the presence of a Git repository
    return vim.fn.isdirectory('.git') == 1
  end,
}
