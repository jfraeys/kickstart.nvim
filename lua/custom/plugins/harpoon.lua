return {
  'theprimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = {
    'nvim-lua/plenary.nvim',
    -- 'nvim-telescope/telescope.nvim',
  },
  config = function()
    local harpoon = require('harpoon')
    -- local actions = require('telescope.actions')
    -- local action_state = require('telescope.actions.state')
    -- local conf = require('telescope.config').values

    harpoon:setup({
      settings = {
        save_on_toggle = true,
        sync_on_ui_close = true,
        key = function()
          return vim.loop.cwd() or 'global'
        end,
      },
    })

    -- Telescope integration
    -- local function toggle_telescope()
    --   local list = harpoon:list()
    --   local file_paths = {}
    --
    --   for _, item in ipairs(list.items) do
    --     table.insert(file_paths, item.value)
    --   end
    --
    --   require('telescope.pickers')
    --     .new({}, {
    --       prompt_title = 'Harpoon',
    --       finder = require('telescope.finders').new_table({
    --         results = file_paths,
    --       }),
    --       previewer = false,
    --       sorter = conf.generic_sorter({}),
    --       layout_config = {
    --         width = 0.5,
    --         height = 0.5,
    --         prompt_position = 'top',
    --       },
    --       layout_strategy = 'vertical',
    --       attach_mappings = function(prompt_bufnr, map)
    --         map('i', '<C-d>', function()
    --           local selection = action_state.get_selected_entry()
    --           if not selection then
    --             return
    --           end
    --
    --           local target = selection[1]
    --           for _, item in ipairs(harpoon:list().items) do
    --             if item.value == target then
    --               harpoon:list():remove(item)
    --               break
    --             end
    --           end
    --           actions.close(prompt_bufnr)
    --           toggle_telescope()
    --         end)
    --         return true
    --       end,
    --     })
    --     :find()
    -- end

    vim.keymap.set('n', '<leader>a', function()
      if vim.fn.expand('%:p'):sub(1, 6) == 'oil://' then
        return
      end

      harpoon:list():add()
    end, { desc = 'Harpoon: Add file to list (if not already present)' })

    vim.keymap.set('n', '<C-e>', function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { desc = 'Harpoon: Toggle quick menu' })

    vim.keymap.set('n', '<C-h>', function()
      harpoon:list():select(1)
    end)
    vim.keymap.set('n', '<C-j>', function()
      harpoon:list():select(2)
    end)
    vim.keymap.set('n', '<C-k>', function()
      harpoon:list():select(3)
    end)
    vim.keymap.set('n', '<C-l>', function()
      harpoon:list():select(4)
    end)

    vim.keymap.set('n', '<C-S-p>', function()
      harpoon:list():prev()
    end)
    vim.keymap.set('n', '<C-S-n>', function()
      harpoon:list():next()
    end)
  end,
}
