--- Extensions.
--- API used to manage and register third party scnvim extensions.
--- Heavily inspired by the extension model used by telescope.nvim
--- https://github.com/nvim-telescope/telescope.nvim
---@module scnvim.extensions
---@local
local config = require 'scnvim.config'
local path = require 'scnvim.path'
local M = {}

M._health = {}
M._linked = {}

local function link_classes(name)
  local ok, root_dir, sc_ext_dir
  ok, root_dir = pcall(path.get_plugin_root_dir, name)
  if not ok then
    return root_dir
  end
  ok, sc_ext_dir = pcall(path.get_user_extension_dir)
  if not ok then
    return sc_ext_dir
  end
  local source_dir = path.concat(root_dir, 'supercollider')
  local dest_dir = path.concat(sc_ext_dir, 'scnvim-extensions')
  if path.exists(source_dir) then
    vim.fn.mkdir(dest_dir, 'p')
    local link_path = path.concat(dest_dir, name)
    path.link(source_dir, link_path)
    return link_path
  end
  return nil
end

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
    M._linked[k] = link_classes(k)
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

local function get_keys(t)
  local keys = {}
  for name in pairs(t) do
    keys[#keys + 1] = name
  end
  table.sort(keys)
  return keys
end

local function filter(t, str)
  if not str or #str == 0 then
    return t
  end
  return vim.tbl_filter(function(s)
    return s:match(str) ~= nil
  end, t)
end

--- User command completion callback
---@local
function M.cmd_complete(arglead, cmdline, cursorpos) -- luacheck: ignore
  local extensions = filter(get_keys(M.manager), arglead)
  local fullmatch = arglead:match '(.*%.)'
  if fullmatch then
    local ext_name = fullmatch:sub(1, -2)
    local meth_name = vim.split(arglead, '.', { plain = true })[2]
    local exports = filter(get_keys(M.manager[ext_name]), meth_name)
    for i, fname in ipairs(exports) do
      exports[i] = ext_name .. '.' .. fname
    end
    return exports
  end
  return extensions
end

return M
