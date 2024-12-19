return {
  'neovim/nvim-lspconfig',
  dependencies = {
    { 'williamboman/mason.nvim', config = true },
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',

    -- Useful status updates for LSP
    {
      'j-hui/fidget.nvim',
      tag = 'legacy',
      opts = {},
      event = 'LspAttach', -- Lazy load on LSP attachment
    },

    {
      'ray-x/lsp_signature.nvim',
      event = 'LspAttach',
    },

    -- Treesitter for better UI and syntax
    {
      'nvim-treesitter/nvim-treesitter',
      build = ':TSUpdate',
      event = 'BufReadPost',
      opts = {
        highlight = { enable = true },
        indent = { enable = true },
        ensure_installed = 'all', -- Alternatively, specify a list of languages
      },
    },

    -- venv-selector for Python virtual environments
    {
      'williamboman/venv-selector.nvim',
      event = 'BufReadPost',
    },

    {
      'nvim-treesitter/nvim-treesitter-textobjects',
      event = 'BufReadPost',
    },

    -- UI enhancements
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
  },
  config = function()
    -- Enhanced capabilities for LSP servers
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local has_cmp, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
    if has_cmp then
      capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
    end

    -- Default on_attach function
    local on_attach = function(client, bufnr)
      vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
      require('lsp_signature').on_attach({ hint_enable = false, handler_opts = { border = 'rounded' } }, bufnr)

      local function nmap(keys, func, desc)
        if desc then
          desc = 'LSP: ' .. desc
        end
        vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
      end

      -- Key mappings
      nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
      nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
      nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
      nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
      nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
      nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
      nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

      -- Diagnostics
      nmap('<leader>e', vim.diagnostic.open_float, 'Show line [E]rrors')
      nmap('[d', vim.diagnostic.goto_prev, 'Previous Diagnostic')
      nmap(']d', vim.diagnostic.goto_next, 'Next Diagnostic')

      -- Code Actions and Refactoring
      nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
      nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

      -- Documentation
      nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
      nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

      -- Highlight symbol under cursor
      if client.server_capabilities.documentHighlightProvider then
        local highlight_group = vim.api.nvim_create_augroup('lsp_document_highlight', { clear = false })

        -- Create a subtle highlight style (modify to your preference)
        vim.api.nvim_set_hl(0, 'LspDocumentHighlight', {
          background = '#3e3e3e', -- darker background for subtle effect
          foreground = '#a0a0a0', -- lighter color for text, to reduce intensity
          underline = false,
        })

        -- Apply subtle highlighting on cursor hold
        -- vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        --   buffer = bufnr,
        --   group = highlight_group,
        --   callback = vim.lsp.buf.document_highlight,
        -- })

        -- Clear references less aggressively
        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
          buffer = bufnr,
          group = highlight_group,
          callback = vim.lsp.buf.clear_references,
        })
      end
    end

    -- Default LSP configuration
    local default_config = {
      capabilities = capabilities,
      on_attach = on_attach,
    }

    require('venv-selector').setup({
      auto_activate = true,
    })

    -- Server-specific configurations
    local servers = {
      bashls = { filetypes = { 'sh', 'bash' } },
      clangd = {
        cmd = {
          'clangd',
          '--background-index',
          '--suggest-missing-includes',
          '--clang-tidy',
          '--header-insertion=iwyu',
        },
      },
      gopls = {
        settings = {
          gopls = {
            gofumpt = true,
            staticcheck = true,
            completeUnimported = true,
            usePlaceholders = true,
            analyses = { unusedparams = true, fieldalignment = true },
          },
        },
      },
      pyright = {
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              diagnosticMode = 'workspace',
              useLibraryCodeForTypes = true,
              typeCheckingMode = 'basic',
            },
          },
        },
        root_dir = require('lspconfig/util').root_pattern(
          'pyproject.toml',
          'setup.py',
          'setup.cfg',
          'requirements.txt'
        ),
      },
      ruff = {
        filetypes = { 'python' },
        cmd = { 'ruff', 'server' },
      },
      rust_analyzer = {
        cmd = { 'rustup', 'run', 'stable', 'rust-analyzer' },
        settings = {
          ['rust-analyzer'] = {
            imports = { granularity = { group = 'module' }, prefix = 'self' },
            cargo = { buildScripts = { enable = true } },
            procMacro = { enable = true },
          },
        },
      },
      lua_ls = {
        settings = {
          Lua = {
            runtime = { version = 'LuaJIT', path = vim.split(package.path, ';') },
            diagnostics = { globals = { 'vim' } },
            workspace = { library = vim.api.nvim_get_runtime_file('', true) },
          },
        },
      },
    }

    -- Setup LSP servers using tbl_deep_extend
    require('mason-lspconfig').setup({ ensure_installed = vim.tbl_keys(servers) })
    local lspconfig = require('lspconfig')

    for server, config in pairs(servers) do
      lspconfig[server].setup(vim.tbl_deep_extend('force', default_config, config))
    end

    -- Diagnostics configuration
    vim.diagnostic.config({
      underline = true,
      severity_sort = true,
      signs = true,
      virtual_text = { spacing = 2, prefix = '●' },
      float = { source = 'if_many', border = 'rounded' },
    })

    -- Define diagnostic signs
    local signs = {
      { name = 'DiagnosticSignError', text = '✘' },
      { name = 'DiagnosticSignWarn', text = '▲' },
      { name = 'DiagnosticSignHint', text = '⚑' },
      { name = 'DiagnosticSignInfo', text = '»' },
    }
    for _, sign in ipairs(signs) do
      vim.fn.sign_define(sign.name, { text = sign.text, texthl = sign.name })
    end

    -- Additional plugin setups
    require('fidget').setup({})
  end,
}
