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

--- Run an exported function.
--- This function is called by `SCNvimExt` user command and probably not so useful on its own.
---@param tbl Table returned by `nvim_buf_create_user_command`
function M.run_user_command(tbl)
  local name, cmd = unpack(vim.split(tbl.fargs[1], '.', { plain = true, trimempty = true }))
  local ext = M.manager[name]
  if not ext then
    error(string.format('Extension "%s" is not installed', name))
  end
  if ext[cmd] then
    local args = { select(2, unpack(tbl.fargs)) }
    ext[cmd](unpack(args))
  else
    error(string.format('Could not find exported function "%s"', cmd))
  end
end

return M
