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
--- `scnvim.editor`
---
--- * on_highlight
--- * on_send
---
--- `scnvim.postwin`
---
--- * on_open
---
---@module scnvim.action
local action = {}

local _id = 1000
local function get_next_id()
  local next = _id
  _id = _id + 1
  return next
end

--- Create a new action.
---@param fn The default function to call.
---@return The action.
function action.new(fn)
  local self = setmetatable({}, {
    __index = action,
    __call = function(tbl, ...)
      tbl.default_fn(...)
      for _, obj in ipairs(tbl.appended) do
        obj.fn(...)
      end
    end,
  })
  self._default = fn
  self.default_fn = fn
  self.appended = {}
  return self
end

--- Methods
---@type action

--- Replace the default function.
--- If several extension replace the same function then "last one wins".
--- Consider using `action:append` if your extensions doesn't need to replace the
--- default behaviour.
---@param fn The replacement function. The signature and return values *must*
--- match the function to be replaced.
function action:replace(fn)
  self.default_fn = fn
end

--- Restore the default function.
function action:restore()
  self.default_fn = self._default
end

--- Append a function.
--- The appended function will run after the default function and will receive
--- the same input arguments. There can be several appended functions and they
--- will be executed in the order they were appended.
---@param fn The function to append.
---@return An integer ID. Use this ID if you need to remove the appended action.
function action:append(fn)
  local id = get_next_id()
  self.appended[#self.appended + 1] = {
    id = id,
    fn = fn,
  }
  return id
end

--- Remove an appended action.
---@param id ID of the action to remove.
function action:remove(id)
  for i, obj in ipairs(self.appended) do
    if obj.id == id then
      table.remove(self.appended, i)
      return
    end
  end
  error('Could not find action with id: ' .. id)
end

return action
