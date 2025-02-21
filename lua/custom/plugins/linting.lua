return {
  'mfussenegger/nvim-lint',
  dependencies = { 'WhoIsSethDaniel/mason-tool-installer.nvim' },
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    -- Set up linters by file type
    local linters_by_ft = {
      python = { 'ruff', 'mypy' },
      go = { 'golangcilint' }, -- nvim-lint expects 'golangcilint'
      yaml = { 'yamllint' },
      bash = { 'shellcheck' },
      lua = { 'luacheck' },
      -- rust = { 'clippy' },
      dockerfile = { 'hadolint' },
    }

    -- Set linters in nvim-lint
    require('lint').linters_by_ft = linters_by_ft

    -- Mapping for Mason's names to nvim-lint's expected names
    local mason_to_lint = {
      golangcilint = 'golangci-lint', -- Installed as 'golangci-lint', used as 'golangcilint'
    }

    -- Gather and deduplicate linters
    local tools = {}
    for _, linters in pairs(linters_by_ft) do
      for _, linter in ipairs(linters) do
        table.insert(tools, mason_to_lint[linter] or linter)
      end
    end

    -- Install required linters using Mason
    require('mason-tool-installer').setup({ ensure_installed = tools })

    -- Auto-command for linting
    local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
      group = lint_augroup,
      callback = function()
        require('lint').try_lint()
      end,
    })
  end,
}
