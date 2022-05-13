local editor = require 'scnvim.editor'
local M = {}

setmetatable(M, {
  __call = function(_, modes, fn, callback, flash)
    if type(modes) == 'string' then
      modes = { modes }
    end
    modes = modes or { 'n' }
    flash = flash or true
    local tmp = editor[fn]
    if not tmp then
      error('[scnvim]: Could not find function ' .. fn)
    end
    fn = function()
      tmp(callback, flash)
    end
    return { modes = modes, fn = fn }
  end,
})

function M.setup(config)
  local function apply_keymaps()
    for k, v in pairs(config.mapping) do
      if v[1] ~= nil then
        for _, v1 in ipairs(v) do
          vim.keymap.set(v1.modes, k, v1.fn, { buffer = true })
        end
      else
        vim.keymap.set(v.modes, k, v.fn, { buffer = true })
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
