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

    -- Additional Lua configuration
    'folke/neodev.nvim',
  },
  config = function()
    -- General capabilities for LSP servers
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local has_cmp, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
    if has_cmp then
      capabilities = cmp_nvim_lsp.default_capabilities()
    end

    -- LSP server configurations
    local servers = {
      bashls = { filetypes = { 'sh', 'bash' } },
      clangd = {},
      gopls = {
        settings = {
          gopls = {
            gofumpt = true,
            staticcheck = true,
            completeUnimported = true,
            usePlaceholders = true,
            analyses = {
              unusedparams = true,
            },
          },
        },
      },
      pyright = {
        filetypes = { 'python' },
        settings = {
          pyright = {
            disableOrganizeImports = false,
          },
          python = {
            analysis = {
              autoSearchPaths = false,
              diagnosticMode = 'workspace',
              useLibraryCodeForTypes = true,
              typeCheckingMode = 'off',
              ignore = { '*' },
            },
          },
        },
      },
      ruff = {
        filetypes = { 'python' },
        cmd = { 'ruff', 'server' },
      },
      rust_analyzer = {
        cmd = { 'rustup', 'run', 'stable', 'rust-analyzer' },
      },
      texlab = {
        settings = {
          texlab = {
            build = {
              executable = 'latexmk',
              args = { '-pdf', '-xelatex', '-output-directory=output', '-interaction=nonstopmode', '-synctex=1', '%f' },
              onSave = true,
            },
            forwardSearch = {
              executable = 'zathura',
              args = { '--synctex-forward', '%l:1:%f', '%p' },
            },
          },
        },
      },
      lua_ls = {
        settings = {
          Lua = {
            runtime = { version = 'LuaJIT', path = vim.split(package.path, ';') },
            diagnostics = { globals = { 'vim' } },
            workspace = {
              library = vim.api.nvim_get_runtime_file('', true),
              checkThirdParty = false,
            },
            telemetry = { enable = false },
          },
        },
      },
      marksman = {
        filetypes = { 'markdown' },
        root_dir = function(fname)
          return require('lspconfig.util').root_pattern('.marksman.toml', '.git')(fname) or vim.loop.cwd()
        end,
      },
      yamlls = {
        settings = {
          yaml = {
            schemas = {
              ['https://json.schemastore.org/github-workflow.json'] = '/.github/workflows/*.{yml,yaml}',
            },
          },
        },
      },
      taplo = { filetypes = { 'toml' } },
      dockerls = { filetypes = { 'Dockerfile' } },
    }

    -- Setup LSP servers via mason-lspconfig
    require('mason-lspconfig').setup({
      ensure_installed = vim.tbl_keys(servers),
    })

    -- Attach custom handlers to each server
    local on_attach = function(client, bufnr)
      local function nmap(keys, func, desc)
        if desc then
          desc = 'LSP: ' .. desc
        end
        vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
      end

      nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
      nmap('<leader>ca', function()
        vim.lsp.buf.code_action(require('telescope.themes').get_dropdown({
          winblend = 10,
          previewer = false,
        }))
      end, '[C]ode [A]ction')

      nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
      nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
      nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
      nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
      nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
      nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

      nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
      nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')
    end

    -- Configure each server
    for server, config in pairs(servers) do
      require('lspconfig')[server].setup(vim.tbl_extend('force', {
        capabilities = capabilities,
        on_attach = on_attach,
      }, config))
    end

    -- Diagnostics configuration
    vim.diagnostic.config({
      underline = true,
      severity_sort = true,
      signs = true,
      update_in_insert = false,
      virtual_text = {
        spacing = 2,
      },
      float = {
        source = 'if_many',
        border = 'rounded',
      },
    })

    -- Define diagnostic signs
    local sign = function(opts)
      vim.fn.sign_define(opts.name, {
        texthl = opts.name,
        text = opts.text,
        numhl = opts.name,
      })
    end

    sign({ name = 'DiagnosticSignError', text = '✘' })
    sign({ name = 'DiagnosticSignWarn', text = '▲' })
    sign({ name = 'DiagnosticSignHint', text = '⚑' })
    sign({ name = 'DiagnosticSignInfo', text = '»' })

    -- Additional setups
    require('fidget').setup({})
    require('neodev').setup({
      library = {
        plugins = { 'nvim-dap-ui' },
        types = true,
      },
    })
  end,
}

