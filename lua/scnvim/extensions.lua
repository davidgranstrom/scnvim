--- Extensions.
--- API used to manage and register third party scnvim extensions.
--- Heavily inspired by the extension model used by telescope.nvim
--- https://github.com/nvim-telescope/telescope.nvim
---@module scnvim.extensions
---@local
local config = require 'scnvim.config'
local M = {}

M._health = {}

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
    return t[k]
  end,
})

--- Register an extension.
---@param ext The extension to register.
---@return The extension.
function M.register(ext)
  return ext
end

--- Load an extension.
---@param name The extension to load.
---@return The exported extension API.
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
    ext[cmd](select(2, unpack(tbl.fargs)))
  else
    error(string.format('Could not find exported function "%s"', cmd))
  end
end

return M
