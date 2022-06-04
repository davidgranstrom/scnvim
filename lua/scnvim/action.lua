--- Define actions.
--- An action defines an object that can be overriden by the user or by an extension.
---
--- **Actions overview**
---
--- See the corresponding module for detailed documentation.
---
--- `scnvim.sclang`
---
--- * on_init
--- * on_exit
--- * on_output
---
--- `scnvim.help`
---
--- * on_open
--- * on_select
---
---@module scnvim.action
local action = {}

--- Create a new action.
---@param fn The default function to call.
---@return The action.
function action.new(fn)
  local self = setmetatable({}, {
    __index = action,
    __call = function(tbl, ...)
      tbl.default_fn(...)
      for _, func in ipairs(tbl.appended) do
        func(...)
      end
    end,
  })
  self.default_fn = fn
  self.appended = {}
  return self
end

--- Replace the default function.
---@param fn The replacement function. The signature and return values *must*
--- match the function to be replaced.
function action:replace(fn)
  self.default_fn = fn
end

--- Append a function.
--- The appended function will run after the default function and will receive
--- the same input arguments. There can be several appended functions and they
--- will be executed in the order they were appended.
---@param fn The function to append.
function action:append(fn)
  table.insert(self.appended, fn)
end

return action
