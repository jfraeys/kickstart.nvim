return {
  -- Add the nvim-dap related plugins
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      { 'rcarriga/nvim-dap-ui', cmd = { 'DapUI' } },
      { 'nvim-neotest/nvim-nio' },
      { 'thehamsta/nvim-dap-virtual-text', ft = { 'python', 'go', 'rust' } },
      { 'mfussenegger/nvim-dap-python', ft = 'python' },
      { 'leoluz/nvim-dap-go', ft = 'go' },
      { 'simrat39/rust-tools.nvim', ft = 'rust' },
      'williamboman/mason.nvim', -- Mason for managing external tools
      'williamboman/mason-lspconfig.nvim',
      'jay-babu/mason-nvim-dap.nvim', -- Ensures dap installations via Mason
    },
    config = function()
      local dap = require('dap')
      local dapui = require('dapui')
      local dap_virtual_text = require('nvim-dap-virtual-text')
      local mason_dap = require('mason-nvim-dap')

      -- Setup dap-ui and dap-virtual-text
      dapui.setup()
      dap_virtual_text.setup()

      -- Ensure Mason installs required debuggers
      mason_dap.setup({
        ensure_installed = { 'codelldb', 'python', 'delve' }, -- C/C++, Python, Go
        automatic_setup = true,
      })

      -- Auto open/close dap-ui on debugging events
      dap.listeners.after.event_initialized['dapui_config'] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated['dapui_config'] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited['dapui_config'] = function()
        dapui.close()
      end

      -- Define breakpoint signs
      vim.fn.sign_define('DapBreakpoint', { text = '🔴', texthl = '', linehl = '', numhl = '' })
      vim.fn.sign_define('DapStopped', { text = '🟢', texthl = '', linehl = '', numhl = '' })
    end,
    keys = {
      {
        '<leader>dc',
        function()
          require('dap').continue()
        end,
        mode = 'n',
        noremap = true,
        silent = true,
        desc = 'Continue debugging',
      },
      {
        '<leader>ds',
        function()
          require('dap').step_over()
        end,
        mode = 'n',
        noremap = true,
        silent = true,
        desc = 'Step over',
      },
      {
        '<leader>di',
        function()
          require('dap').step_into()
        end,
        mode = 'n',
        noremap = true,
        silent = true,
        desc = 'Step into',
      },
      {
        '<leader>do',
        function()
          require('dap').step_out()
        end,
        mode = 'n',
        noremap = true,
        silent = true,
        desc = 'Step out',
      },
      {
        '<leader>db',
        function()
          require('dap').toggle_breakpoint()
        end,
        mode = 'n',
        noremap = true,
        silent = true,
        desc = 'Toggle breakpoint',
      },
      {
        '<leader>dsb',
        function()
          require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))
        end,
        mode = 'n',
        noremap = true,
        silent = true,
        desc = 'Set conditional breakpoint',
      },
      {
        '<leader>dr',
        function()
          require('dap').repl.open()
        end,
        mode = 'n',
        noremap = true,
        silent = true,
        desc = 'Open REPL',
      },
      {
        '<leader>du',
        function()
          require('dapui').toggle()
        end,
        mode = 'n',
        noremap = true,
        silent = true,
        desc = 'Toggle Dap UI',
      },
    },
    ft = { 'python', 'go', 'rust' },
  },
}
