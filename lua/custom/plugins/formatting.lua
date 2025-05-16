return {
  'stevearc/conform.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
  },
  event = { 'BufReadPre', 'BufNewFile' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>f',
      function()
        require('conform').format({ async = true, lsp_fallback = true })
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
  },
  opts = function()
    local formatters_by_ft = {
      lua = { 'stylua' },
      python = function(bufnr)
        if require('conform').get_formatter_info('ruff_format', bufnr).available then
          return { 'isort', 'ruff_format', 'ruff_fix' }
        else
          return { 'isort', 'black' }
        end
      end,
      go = { 'gofumpt', 'goimports' },
      yaml = { 'yamlfmt' },
      bash = { 'shfmt' },
      rust = {},
      -- dockerfile = { 'hadolint' },
      c = { 'clang-format' },
    }

    return {
      notify_on_error = false,
      format_on_save = function(bufnr)
        local disable_filetypes = { c = true, cpp = true }
        return not disable_filetypes[vim.bo[bufnr].filetype]
          and {
            timeout_ms = 500,
            lsp_fallback = true,
          }
      end,
      formatters_by_ft = formatters_by_ft,
    }
  end,
  config = function(_, opts)
    require('conform').setup(opts)

    -- Automatically gather and deduplicate tools
    local formatters = opts.formatters_by_ft
    local tools = {}
    for _, formatter in pairs(formatters) do
      if type(formatter) == 'table' then
        vim.list_extend(tools, formatter)
      end
    end

    -- Deduplicate tools
    local unique_tools = {}
    for _, tool in ipairs(tools) do
      unique_tools[tool] = true
    end
    tools = vim.tbl_keys(unique_tools)

    -- Install required tools
    require('mason-tool-installer').setup({
      ensure_installed = tools,
    })
  end,
}
