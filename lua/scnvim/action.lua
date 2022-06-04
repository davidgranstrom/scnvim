--- Define actions.
--- An action can be overriden by the user or by an extension
---@module action
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

--- Replace the default action.
---@param fn The replacement function. The signature and return values *must*
--- match the default function.
function action:replace(fn)
  self.default_fn = fn
end

--- Append an action.
--- The appended action will run after the default function and receive its return values as input.
---@param fn The function to append. The signature and return values *must*
--- match the default function.
function action:append(fn)
  table.insert(self.appended, fn)
end

return action
