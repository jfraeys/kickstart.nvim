-- get schema for current buffer
local function get_schema()
  local schema = require('yaml-companion').get_buf_schema(0)
  if schema.result[1].name == 'none' then
    return ''
  end
  return schema.result[1].name
end
