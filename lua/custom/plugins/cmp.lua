return {
  'hrsh7th/nvim-cmp',
  dependencies = {
    -- Core snippet engine and integration
    { 'L3MON4D3/LuaSnip', lazy = true },
    { 'saadparwaiz1/cmp_luasnip', lazy = true },

    -- LSP support for autocompletion
    { 'hrsh7th/cmp-nvim-lsp' },

    -- Predefined snippets, loaded on demand
    { 'rafamadriz/friendly-snippets', lazy = true },

    -- Additional sources for path and buffer completion
    { 'hrsh7th/cmp-path', lazy = true },
    { 'hrsh7th/cmp-buffer', lazy = true },

    -- Sources for command-line and git completion
    { 'hrsh7th/cmp-cmdline', lazy = true },
    { 'petertriho/cmp-git', lazy = true, ft = { 'gitcommit' } },

    -- UI enhancements for the completion menu
    { 'onsails/lspkind-nvim', lazy = true },
  },
  event = { 'InsertEnter', 'CmdlineEnter' },
  config = function()
    local cmp = require('cmp')
    local luasnip = require('luasnip')
    local lspkind = require('lspkind')

    -- Set Vim's completion options
    vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }

    -- Load LuaSnip snippets dynamically
    luasnip.config.setup({
      history = true,
      updateevents = 'TextChanged,TextChangedI',
    })
    require('luasnip.loaders.from_vscode').lazy_load()

    -- Define reusable mappings
    local function custom_mappings(mode)
      return {
        ['<C-n>'] = cmp.mapping.select_next_item(),
        ['<C-p>'] = cmp.mapping.select_prev_item(),
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, { mode }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { mode }),
        ['<CR>'] = cmp.mapping.confirm({ select = false }),
      }
    end

    -- Configure completion sources and appearance
    local function cmp_sources()
      return cmp.config.sources({
        { name = 'nvim_lsp', priority = 1000 },
        { name = 'luasnip', priority = 900 },
        { name = 'path', priority = 750 },
        { name = 'buffer', priority = 500, keyword_length = 5 },
      })
    end

    local function cmp_format()
      return lspkind.cmp_format({
        mode = 'symbol_text',
        maxwidth = 50,
        ellipsis_char = '...',
        menu = {
          nvim_lsp = '[LSP]',
          luasnip = '[Snip]',
          buffer = '[Buffer]',
          path = '[Path]',
        },
      })
    end

    -- Main nvim-cmp setup
    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      sources = cmp_sources(),
      mapping = cmp.mapping.preset.insert(custom_mappings('i')),
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
      formatting = {
        format = cmp_format(),
      },
    })

    -- Cmdline completion setup
    cmp.setup.cmdline({ '/', '?' }, {
      mapping = cmp.mapping.preset.cmdline(custom_mappings('c')),
      sources = {
        { name = 'buffer', keyword_length = 5 },
      },
    })

    cmp.setup.cmdline(':', {
      mapping = cmp.mapping.preset.cmdline(custom_mappings('c')),
      sources = cmp.config.sources({
        { name = 'path' },
        { name = 'cmdline' },
      }),
      window = {
        documentation = false,
      },
    })

    -- Git-specific completion
    cmp.setup.filetype('gitcommit', {
      sources = cmp.config.sources({
        { name = 'git', priority = 900 },
        { name = 'buffer', keyword_length = 5 },
      }),
    })
  end,
}
