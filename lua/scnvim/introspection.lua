--- SuperCollider introspection
-- @module scnvim
-- @author David Granström
-- @license GPLv3

local M = {}
M.class_map = {}
M.method_map = {}

local Class = {}
Class.__index = Class

function Class.new(tbl)
  local defaults = {}
  defaults.name = nil
  defaults.meta_class = nil
  defaults.super_class = nil
  defaults.methods = {}
  defaults.definition = {
    path = '',
    position = 0,
  }
  return setmetatable(tbl or defaults, Class)
end

function Class:is_subclass_of(parent_class)
  if self.super_class == parent_class then
    return true
  end
  if not self.super_class then
    return false
  end
  return self.super_class:is_subclass_of(parent_class)
end

local Method = {}
Method.__index = Method
Method.SignatureWithoutArguments = 1
Method.SignatureWithArguments = 2
Method.SignatureWithArgumentsAndDefaultValues = 3

function Method.new(tbl)
  local defaults = {}
  defaults.signature_style = -1
  defaults.owner_class = Class.new()
  defaults.name = ''
  defaults.arguments = {}
  defaults.definition = {
    path = '',
    position = 0,
  }
  return setmetatable(tbl or defaults, Method)
end

-- function Method:signature(style)
-- end

-- function Method:matches(to_match)
-- end

-- local function make_full_method_name(class_name, method_name)
--   local ret = class_name
--   if ret:match('^Meta_') then
--     ret = ret:sub(1, 6)
--     ret = '-*' .. ret
--   else
--     ret = '-' .. ret
--   end
--   return method_name .. ret
-- end

function M.parse(str)
  for _, entry in ipairs(str) do
    assert(type(entry) == 'table')
    local name = entry[1]
    M.class_map[name] = Class.new{name = name, methods = {}}
  end

  for _, entry in ipairs(str) do
    local name = entry[1]
    local class = M.class_map[name]
    assert(class)
    local metaclass_name = entry[2]
    local metaclass = M.class_map[metaclass_name]
    class.meta_class = metaclass
    if #entry[3] == 0 then
      class.super_class = 0
    else
      local superclass_name = entry[3]
      local superclass = M.class_map[superclass_name]
      class.super_class = superclass
    end
    class.definition = {}
    class.definition.path = entry[4]
    class.definition.position = tonumber(entry[5])

    local methods = entry[6]
    for _, m_entry in ipairs(methods) do
      local method = Method.new{
        owner_class = class,
        name = m_entry[2],
        definition = {
          path = m_entry[3],
          position = tonumber(m_entry[4])
        },
        arguments = {},
      }
      local arguments = m_entry[5]
      for _, arg_entry in ipairs(arguments) do
        local argument = {}
        argument.name = arg_entry[1]
        local defaultValue = arg_entry[2]
        if defaultValue and #defaultValue > 0 then
          argument.defaultValue = defaultValue
        end
        method.arguments[#method.arguments + 1] = argument
      end
      class.methods[#class.methods + 1] = method
      M.method_map[method.name] = method
    end
    table.sort(class.methods, function(a, b)
      return a.name < b.name
    end)
  end
end

return M
