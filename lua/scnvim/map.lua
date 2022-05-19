--- Helper object to define a mapping.
--- Usually used exported from the scnvim module
---@module scnvim.map
---@see scnvim.editor
---@see scnvim
---@usage map.action(modes, callback, flash)
---@usage scnvim.map.send_line({'i', 'n'})
---@local

local editor = require 'scnvim.editor'

return setmetatable({}, {
  __index = function(_, key)
    local fn = editor[key]
    if not fn then
      error('[scnvim]: No such function ' .. key)
    end
    return function(modes, callback, flash)
      modes = type(modes) == 'string' and { modes } or modes
      flash = flash or true
      local wrapper = function()
        fn(callback, flash)
      end
      return { modes = modes, fn = wrapper }
    end
  end,
})
