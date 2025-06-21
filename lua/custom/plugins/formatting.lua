return {
  'stevearc/conform.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
  },
  event = { 'BufReadPre', 'BufNewFile' },
  cmd = { 'ConformInfo' },
  -- Removed keys mapping for manual trigger

  opts = function()
    local formatters_by_ft = {
      lua = { 'stylua' },
      python = { 'ruff', 'black', 'isort' },
      go = { 'gofumpt', 'goimports' },
      yaml = { 'yamlfmt' },
      sh = { 'shfmt' },
      rust = {},
      c = { 'clang-format' },
      sql = { 'sqlfluff' },
    }

    return {
      notify_on_error = false,
      format_on_save = function(bufnr)
        local disable_filetypes = { c = true, cpp = true }
        return not disable_filetypes[vim.bo[bufnr].filetype]
          and {
            timeout_ms = 3000,
            lsp_fallback = true,
          }
      end,
      formatters_by_ft = formatters_by_ft,
    }
  end,

  config = function(_, opts)
    local conform = require('conform')
    conform.setup(opts)

    -- Gather formatters to install (same as before)
    local formatters = opts.formatters_by_ft
    local tools_set = {}

    for _, val in pairs(formatters) do
      local tool_list = {}

      if type(val) == 'function' then
        local ok, result = pcall(val, 0)
        if ok and type(result) == 'table' then
          tool_list = result
        end
      elseif type(val) == 'table' then
        tool_list = val
      end

      for _, tool in ipairs(tool_list) do
        tools_set[tool] = true
      end
    end

    local tools = vim.tbl_keys(tools_set)

    require('mason-tool-installer').setup({
      ensure_installed = tools,
      auto_update = false,
      run_on_start = true,
    })

    -- Set up autocommand to format on save
    local augroup = vim.api.nvim_create_augroup('ConformFormatOnSave', { clear = true })
    vim.api.nvim_create_autocmd('BufWritePre', {
      group = augroup,
      callback = function()
        local bufnr = vim.api.nvim_get_current_buf()
        local format_opts = opts.format_on_save and opts.format_on_save(bufnr)
        if format_opts then
          conform.format(vim.tbl_extend('force', format_opts, { async = false }))
        end
      end,
    })
  end,
}
