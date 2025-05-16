return {
  'hrsh7th/nvim-cmp',
  event = { 'InsertEnter', 'CmdlineEnter' },
  dependencies = {
    -- Core snippet engine and integration
    { 'L3MON4D3/LuaSnip' },
    { 'saadparwaiz1/cmp_luasnip' },

    -- LSP support
    { 'hrsh7th/cmp-nvim-lsp' },

    -- Predefined snippets, lazy-loaded
    { 'rafamadriz/friendly-snippets' },

    -- Additional sources
    { 'hrsh7th/cmp-path' },
    { 'hrsh7th/cmp-buffer', event = 'InsertEnter' },

    -- Cmdline & git
    { 'hrsh7th/cmp-cmdline' },
    { 'petertriho/cmp-git', ft = { 'gitcommit' } },

    -- UI enhancement
    { 'onsails/lspkind-nvim' },
  },
  config = function()
    local cmp = require('cmp')
    local luasnip = require('luasnip')
    local lspkind = require('lspkind')

    -- Load friendly snippets
    require('luasnip.loaders.from_vscode').lazy_load()

    vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }

    luasnip.config.setup({
      history = true,
      updateevents = 'TextChanged,TextChangedI',
    })

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

    local function cmp_sources()
      return cmp.config.sources({
        { name = 'nvim_lsp', priority = 1000 },
        { name = 'luasnip', priority = 900 },
        { name = 'path', priority = 750 },
        { name = 'buffer', priority = 500, keyword_length = 5 },
      })
    end

    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert(custom_mappings('i')),
      sources = cmp_sources(),
      formatting = {
        fields = { 'abbr', 'kind', 'menu' },
        expandable_indicator = false,
        format = lspkind.cmp_format({
          mode = 'symbol_text',
          maxwidth = 50,
          ellipsis_char = '...',
          menu = {
            nvim_lsp = '[LSP]',
            luasnip = '[Snip]',
            buffer = '[Buffer]',
            path = '[Path]',
          },
        }),
      },
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
      performance = {
        filtering_context_budget = 5,
        async_budget = 1,
        confirm_resolve_timeout = 100,
        max_view_entries = 20,
        debounce = 60,
        throttle = 30,
        fetching_timeout = 200,
      },
    })

    -- Search (`/`, `?`)
    cmp.setup.cmdline({ '/', '?' }, {
      mapping = cmp.mapping.preset.cmdline(custom_mappings('c')),
      sources = {
        { name = 'buffer', keyword_length = 5 },
      },
    })

    -- Command line (`:`)
    cmp.setup.cmdline(':', {
      mapping = cmp.mapping.preset.cmdline(custom_mappings('c')),
      sources = cmp.config.sources({
        { name = 'path' },
        { name = 'cmdline' },
      }),
      window = {
        documentation = cmp.config.window.bordered({
          winhighlight = 'Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None',
          border = 'rounded',
        }),
      },
    })

    -- Git commit
    cmp.setup.filetype('gitcommit', {
      sources = cmp.config.sources({
        { name = 'git', priority = 900 },
        { name = 'buffer', keyword_length = 5 },
      }),
    })
  end,
}
