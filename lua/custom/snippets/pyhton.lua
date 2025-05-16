local ls = require('luasnip')

local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local d = ls.dynamic_node
local sn = ls.snippet_node

-- Helper to parse function args and create insert nodes
local function generate_arg_docs()
  local line = vim.api.nvim_get_current_line()
  local args = line:match('def%s+[%w_]+%((.*)%)')
  if not args then
    return sn(nil, { t('Args:') })
  end

  local nodes = { t('Args:') }
  local index = 1

  for arg in args:gmatch('[^,%s]+') do
    table.insert(nodes, t({ '', '    ' .. arg .. ': ' }))
    table.insert(nodes, i(index))
    index = index + 1
  end

  return sn(nil, nodes)
end

-- Add Python snippets
ls.add_snippets('python', {
  s('log', {
    t({ 'LOG.' }),
    i(1, 'level'),
    t({ '(' }),
    i(2, 'message'),
    t({ ')' }),
  }),

  s('#!', {
    t({ '#!/usr/bin/env python' }),
  }),

  -- Docstring with Args (interactive) and Returns
  s('doc', {
    t({ '"""' }),
    d(1, generate_arg_docs, {}),
    t({ '', '', 'Returns:', '    ' }),
    i(2, 'return_value_description'),
    t({ '', '"""' }),
  }),
})
