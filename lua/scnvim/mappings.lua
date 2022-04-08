local map = {}

setmetatable(map, {
  __call = function(_, fn, modes)
    if type(fn) == 'function' then
      local m = {}
      for _, mode in ipairs(modes) do
        m[mode] = fn
      end
      return m
    end
  end
})

function M.set_keymap(tbl)
  for k, v in pairs(tbl) do

  end
end

return map
