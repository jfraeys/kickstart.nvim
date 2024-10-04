return {
  {
    'L3MON4D3/LuaSnip',
    version = 'v2.*', -- Follows the latest major release version 2
    build = 'make install_jsregexp', -- Optional: install JavaScript-based regular expressions

    dependencies = { 'rafamadriz/friendly-snippets' },

    config = function()
      local luasnip = require('luasnip')

      -- Extend filetypes with specific snippets
      luasnip.filetype_extend('javascript', { 'jsdoc' })
      luasnip.filetype_extend('python', { 'google' })

      -- Key mappings for LuaSnip
      vim.keymap.set({ 'i' }, '<C-s>e', function()
        if luasnip.expand_or_jumpable() then
          luasnip.expand()
        end
      end, { silent = true, desc = 'Expand snippet' })

      vim.keymap.set({ 'i', 's' }, '<C-s>;', function()
        if luasnip.jumpable(1) then
          luasnip.jump(1)
        end
      end, { silent = true, desc = 'Jump forward in snippet' })

      vim.keymap.set({ 'i', 's' }, '<C-s>,', function()
        if luasnip.jumpable(-1) then
          luasnip.jump(-1)
        end
      end, { silent = true, desc = 'Jump backward in snippet' })

      vim.keymap.set({ 'i', 's' }, '<C-s>', function()
        if luasnip.choice_active() then
          luasnip.change_choice(1)
        end
      end, { silent = true, desc = 'Cycle through snippet choices' })
    end,
  },
}
