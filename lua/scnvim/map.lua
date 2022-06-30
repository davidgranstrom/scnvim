--- Helper object to define a keymap.
--- Usually used exported from the scnvim module
---@module scnvim.map
---@see scnvim.editor
---@see scnvim
---@usage map.action(modes, callback, flash)
---@usage scnvim.map.send_line({'i', 'n'})

--- Valid modules.
---@table modules
---@field editor
---@field postwin
---@field sclang
---@field signature
local modules = {
  'editor',
  'postwin',
  'sclang',
  'scnvim',
  'signature',
}

local function validate(str)
  local module, fn = unpack(vim.split(str, '.', { plain = true }))
  if not fn then
    error(string.format('"%s" is not a valid input string to map', str), 0)
  end
  local res = vim.tbl_filter(function(m)
    return module == m
  end, modules)
  local valid_module = #res == 1
  if not valid_module then
    error(string.format('"%s" is not a valid module to map', module), 0)
  end
  if module ~= 'scnvim' then
    module = 'scnvim.' .. module
  end
  return module, fn
end

local map = setmetatable({}, {
  __call = function(_, fn, modes, callback, flash)
    modes = type(modes) == 'string' and { modes } or modes
    modes = modes or { 'n' }
    if type(fn) == 'string' then
      local module, cmd = validate(fn)
      local wrapper = function()
        if module == 'scnvim.editor' then
          require(module)[cmd](callback, flash)
        else
          require(module)[cmd]()
        end
      end
      return { modes = modes, fn = wrapper }
    elseif type(fn) == 'function' then
      return { modes = modes, fn = fn }
    end
  end,
})

local map_expr = function(expr, modes, silent)
  modes = type(modes) == 'string' and { modes } or modes
  silent = silent == nil and true or silent
  return map(function()
    require('scnvim.sclang').send(expr, silent)
  end, modes)
end

return {
  map = map,
  map_expr = map_expr,
}
