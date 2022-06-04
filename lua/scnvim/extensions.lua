--- Extensions
---@module extensions
local config = require 'scnvim.config'
local M = {}

M._health = {}
M._loaded = {}

local function load_extension(name)
  local ok, ext = pcall(require, 'scnvim._extensions.' .. name)
  if not ok then
    error(string.format('[scnvim] "%s" was not found', name))
  end
  if ext.setup then
    local ext_config = config.extensions[name] or {}
    ext.setup(ext_config, config)
  end
  return ext
end

M.manager = setmetatable({}, {
  __index = function(t, k)
    local ext = load_extension(k)
    t[k] = ext.exports or {}
    M._health[k] = ext.health
    M._loaded[#M._loaded + 1] = k
    return t[k]
  end,
})

function M.register(ext)
  return ext
end

function M.load(name)
  return M.manager[name]
end

return M
