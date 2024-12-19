-- Set buffer-local options for Rust files
vim.opt_local.expandtab = true -- Use spaces instead of tabs
vim.opt_local.autoindent = true -- Maintain indentation levels
vim.opt_local.smartindent = true -- Smart indentation
vim.opt_local.shiftwidth = 4 -- Indent width
vim.opt_local.tabstop = 4 -- Tab width
vim.opt_local.softtabstop = 4 -- Soft tab width for alignment
vim.opt_local.textwidth = 80 -- Maximum text width
vim.opt_local.colorcolumn = '80' -- Highlight column 80

-- Define key mappings for Rust with Cargo commands
vim.keymap.set(
  'n',
  '<leader>r',
  '<CMD>Cargo run<CR>',
  { desc = 'Run the current Rust project', noremap = true, buffer = 0 }
)
vim.keymap.set(
  'n',
  '<leader>c',
  '<CMD>Cargo check<CR>',
  { desc = 'Check the current Rust project', noremap = true, buffer = 0 }
)

-- Rust DAP configuration
local dap = require('dap')
local rust_tools = require('rust-tools')
local mason_registry = require('mason-registry')

-- Ensure codelldb is installed via mason
local function get_codelldb_paths()
  local codelldb_package = mason_registry.get_package('codelldb')
  if not codelldb_package:is_installed() then
    vim.notify('codelldb is not installed. Please install it via mason.nvim.', vim.log.levels.ERROR)
    return nil, nil
  end
  local codelldb_path = codelldb_package:get_install_path()
  local adapter = codelldb_path .. '/extension/adapter/codelldb'
  local lib = codelldb_path .. '/extension/lldb/lib/liblldb.so'
  return adapter, lib
end

local codelldb_adapter, codelldb_lib = get_codelldb_paths()
if codelldb_adapter and codelldb_lib then
  rust_tools.setup({
    tools = {
      autosethints = true,
      inlay_hints = {
        show_parameter_hints = true,
        parameter_hints_prefix = '<- ',
        other_hints_prefix = '=> ',
      },
    },
    server = {
      on_attach = function(_, bufnr)
        -- DAP keymaps for Rust
        vim.api.nvim_buf_set_keymap(
          bufnr,
          'n',
          '<leader>dr',
          '<cmd>RustDebuggables<CR>',
          { noremap = true, silent = true }
        )
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>RustHoverActions<CR>', { noremap = true, silent = true })
      end,
    },
    dap = {
      adapter = require('rust-tools.dap').get_codelldb_adapter(codelldb_adapter, codelldb_lib),
    },
  })
end

-- Define Rust DAP configurations
dap.configurations.rust = {
  {
    type = 'rust',
    request = 'launch',
    name = 'Launch Program',
    program = '${workspaceFolder}/target/debug/${workspaceFolderBasename}',
  },
}
