return {
  'mfussenegger/nvim-lint',
  dependencies = { 'WhoIsSethDaniel/mason-tool-installer.nvim' },
  event = { 'BufReadPre', 'BufNewFile' },
  opts = {
    linters_by_ft = {
      python = { 'ruff', 'mypy' },
      go = { 'golangcilint' },
      yaml = { 'yamllint' },
      sh = { 'shellcheck' },
      lua = { 'luacheck' },
      dockerfile = { 'hadolint' },
      sql = { 'sqlfluff' },
    },
    mason_to_lint = {
      golangcilint = 'golangci-lint',
    },
  },
  config = function(_, opts)
    local lint = require('lint')

    -- Apply filetype mappings
    lint.linters_by_ft = opts.linters_by_ft

    -- Build deduplicated tool list
    local tools = {}
    local seen = {}
    for _, linters in pairs(opts.linters_by_ft) do
      for _, linter in ipairs(linters) do
        local tool = opts.mason_to_lint[linter] or linter
        if not seen[tool] then
          table.insert(tools, tool)
          seen[tool] = true
        end
      end
    end

    -- Setup mason-tool-installer
    require('mason-tool-installer').setup({
      ensure_installed = tools,
      auto_update = false,
      run_on_start = true,
      start_delay = 3000, -- optional delay to avoid race with Mason startup
    })

    -- Autocommand group for linting
    local augroup = vim.api.nvim_create_augroup('LintAutogroup', { clear = true })
    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
      group = augroup,
      callback = function()
        local ft = vim.bo.filetype
        local available = lint.linters_by_ft[ft]
        if not available or #available == 0 then
          return
        else
          local ok, err = pcall(lint.try_lint)
          if not ok then
            vim.notify('[nvim-lint] Error running linter: ' .. err, vim.log.levels.ERROR)
          end
        end
      end,
    })
  end,
}
