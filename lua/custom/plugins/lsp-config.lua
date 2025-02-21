return {
  'neovim/nvim-lspconfig',
  dependencies = {
    { 'williamboman/mason.nvim', config = true },
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    { 'folke/neodev.nvim', config = true }, -- Lua development enhancements

    -- Useful status updates for LSP
    {
      'j-hui/fidget.nvim',
      opts = {}, -- Remove legacy tag for newer versions
      event = 'LspAttach',
    },

    {
      'ray-x/lsp_signature.nvim',
      event = 'LspAttach',
    },

    -- Treesitter configuration
    {
      'nvim-treesitter/nvim-treesitter',
      build = ':TSUpdate',
      event = 'BufReadPost',
      opts = {
        highlight = { enable = true },
        indent = { enable = true },
        ensure_installed = {
          'bash',
          'c',
          'cpp',
          'go',
          'lua',
          'python',
          'rust',
          'vimdoc',
          'vim',
          'yaml',
        },
      },
      config = true,
    },

    -- venv-selector for Python virtual environments
    {
      'linux-cultist/venv-selector.nvim', -- Updated to new maintainer
      event = 'VeryLazy',
      opts = {
        auto_activate = true,
      },
      config = true,
    },

    {
      'nvim-treesitter/nvim-treesitter-textobjects',
      event = 'BufReadPost',
    },

    -- UI enhancements
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
    'b0o/schemastore.nvim', -- Added explicit dependency
  },
  config = function()
    -- Initialize neodev before lspconfig
    require('neodev').setup()

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

      -- Highlight symbol under cursor with improved appearance
      if client.server_capabilities.documentHighlightProvider then
        local highlight_group = vim.api.nvim_create_augroup('lsp_document_highlight', { clear = false })

        -- Get the background color from the 'Visual' highlight group
        local visual_bg = vim.fn.synIDattr(vim.fn.hlID('Visual'), 'bg')

        -- Set LSP reference highlight groups
        vim.api.nvim_set_hl(0, 'LspReferenceText', {
          bg = visual_bg,
        })
        vim.api.nvim_set_hl(0, 'LspReferenceRead', {
          bg = visual_bg,
        })
        vim.api.nvim_set_hl(0, 'LspReferenceWrite', {
          bg = visual_bg,
        })

        -- Add autocommands for better document highlighting
        vim.api.nvim_create_autocmd({ 'CursorHold' }, {
          group = highlight_group,
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.document_highlight()
          end,
        })

        vim.api.nvim_create_autocmd({ 'CursorMoved', 'ModeChanged' }, {
          group = highlight_group,
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.clear_references()
          end,
        })
      end
    end

    -- Default LSP configuration
    local default_config = {
      capabilities = capabilities,
      on_attach = on_attach,
    }

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
          '--completion-style=detailed',
          '--header-insertion-decorators',
          '--query-driver=/usr/bin/clang,/usr/bin/clang++',
          '--enable-config', -- Allow reading .clangd configuration files
        },
        settings = {
          formatting = true,
          inlayHints = {
            designators = true,
            enabled = true,
            parameterNames = true,
            deducedTypes = true,
          },
        },
        filetypes = { 'c', 'cpp', 'objc', 'objcpp' },
      },
      gopls = {
        settings = {
          gopls = {
            gofumpt = true,
            staticcheck = true,
            completeUnimported = true,
            usePlaceholders = true,
            analyses = { unusedparams = true },
          },
        },
      },
      jsonls = {
        settings = {
          json = {
            schemas = require('schemastore').json.schemas(),
            validate = { enable = true },
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
      },
      ruff = { -- Updated name from 'ruff'
        filetypes = { 'python' },
      },
      rust_analyzer = {
        settings = {
          ['rust-analyzer'] = {
            imports = { granularity = { group = 'module' }, prefix = 'self' },
            cargo = { buildScripts = { enable = true } },
            procMacro = { enable = true },
            checkOnSave = { command = 'clippy' },
          },
        },
      },
      taplo = {
        filetypes = { 'toml' },
      },
      yamlls = {
        settings = {
          yaml = {
            schemaStore = { enable = true },
            validate = true,
          },
        },
      },
      lua_ls = {
        settings = {
          Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
          },
        },
      },
      zls = {
        filetypes = { 'zig' },
        zig = {},
      },
    }

    -- Setup LSP servers
    require('mason-lspconfig').setup({
      ensure_installed = vim.tbl_keys(servers),
      automatic_installation = true,
    })

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
  end,
}
