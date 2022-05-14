--- Map
--- Helper class to define mappings
---@module scnvim.map

local editor = require 'scnvim.editor'
local config = require 'scnvim.config'
local M = {}

setmetatable(M, {
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

--- Setup function
---@private
function M.setup()
  local function apply_keymaps()
    for key, value in pairs(config.mapping) do
      -- handle list of mappings to same key
      if value[1] ~= nil then
        for _, v in ipairs(value) do
          vim.keymap.set(v.modes, key, v.fn, { buffer = true })
        end
      else
        vim.keymap.set(value.modes, key, value.fn, { buffer = true })
      end
    end
  end
  local id = vim.api.nvim_create_augroup('scnvim_mappings', { clear = true })
  vim.api.nvim_create_autocmd('FileType', {
    group = id,
    pattern = 'supercollider',
    desc = 'Apply mappings',
    callback = apply_keymaps,
  })
end

return M
