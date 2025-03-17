return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      { 'rcarriga/nvim-dap-ui', cmd = { 'DapUI' } },
      { 'nvim-neotest/nvim-nio' },
      { 'thehamsta/nvim-dap-virtual-text', ft = { 'python', 'go', 'rust', 'c', 'cpp', 'zig' } },
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
        automatic_installation = true,
        ensure_installed = { 'codelldb', 'python', 'delve', 'lldb-vscode' }, -- C/C++, Python, Go, LLDB
        automatic_setup = true,
      })

      -- LLDB setup for C/C++ with ASan using codelldb
      dap.adapters.lldb = {
        type = 'server',
        port = '${port}',
        executable = {
          command = '/usr/bin/codelldb', -- Adjust this path to your codelldb executable
          args = { '--port', '${port}' },
        },
      }

      -- C/C++ with ASan configuration
      dap.configurations.c = {
        {
          name = 'Launch with ASan',
          type = 'lldb',
          request = 'launch',
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
          args = {},
          environment = {
            { name = 'ASAN_OPTIONS', value = 'detect_leaks=1' }, -- Enable ASan leak detection
          },
          preLaunchTask = 'build', -- Assuming you have a build task for your program
        },
      }

      -- C++ inherits C configuration
      dap.configurations.cpp = dap.configurations.c

      -- Python setup with nvim-dap-python
      dap.adapters.python = {
        type = 'executable',
        command = '/usr/bin/python3', -- Adjust the Python interpreter path
        args = { '-m', 'debugpy.adapter' },
      }
      dap.configurations.python = {
        {
          type = 'python',
          request = 'launch',
          name = 'Launch Python File',
          program = '${file}',
        },
      }

      -- Go setup with nvim-dap-go
      dap.adapters.go = {
        type = 'executable',
        command = 'delve',
        name = 'dlv',
        args = { 'debug' },
      }
      dap.configurations.go = {
        {
          name = 'Launch Go Program',
          type = 'go',
          request = 'launch',
          program = '${file}',
        },
      }

      -- Zig (requires a custom adapter, no official dap adapter available yet)
      dap.adapters.zig = {
        type = 'executable',
        command = 'zig',
        args = { 'dbg', '--nocolor', 'run' },
        name = 'zig-dbg',
      }
      dap.configurations.zig = {
        {
          name = 'Launch Zig Program',
          type = 'zig',
          request = 'launch',
          program = '${file}',
        },
      }

      -- Rust setup with rust-tools.nvim
      local rust_tools = require('rust-tools')
      rust_tools.setup({
        server = {
          on_attach = function(client, _)
            -- DAP for Rust setup
            dap.adapters.rust = {
              type = 'executable',
              command = 'rust-gdb', -- Or `rust-lldb`
              name = 'rust-dbg',
            }

            dap.configurations.rust = {
              {
                name = 'Launch Rust Program',
                type = 'rust',
                request = 'launch',
                program = '${file}',
              },
            }
          end,
        },
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
    ft = { 'python', 'go', 'rust', 'c', 'cpp', 'zig' }, -- Added Zig to file types
  },
}
